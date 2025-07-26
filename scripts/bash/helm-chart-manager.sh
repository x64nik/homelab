#!/bin/bash

set -e

REGION="us-west-2"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
DEFAULT_CHART_DIR="/opt/charts"

# ------------------------ Utility Functions ------------------------

auth_ecr() {
    echo "Checking AWS authentication..."
    if aws sts get-caller-identity &> /dev/null; then
        echo "Authenticated with AWS."
        aws ecr get-login-password --region "$REGION" | \
            helm registry login \
                --username AWS \
                --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
    else
        echo "Unauthenticated!!"
        exit 1
    fi
}

logout_ecr() {
    helm registry logout "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com" || true
}

# ------------------------ Help Function ------------------------

show_help() {
    cat << EOF
Usage: $0 <command> [arguments]

Commands:

  ecr helm-create-repository <namespace/repo-name>
      Creates a Helm chart repository in AWS ECR.
      If the repository already exists, a message is printed.

  helm pull <repo-url> [destination-dir]
      Downloads a Helm chart from a public repository.
      Default destination directory is: $DEFAULT_CHART_DIR

  ecr helm-push <chart.tgz path> <namespace/repo-name>
      Pushes a Helm chart to an ECR Helm repository.

  --help
      Display this help message.
EOF
    exit 0
}

# ------------------------ Core Functionalities ------------------------

create_helm_repo() {
    local repo_name="$1"
    if [[ -z "$repo_name" ]]; then
        echo "Repository name required."
        exit 1
    fi

    if aws ecr describe-repositories --repository-names "$repo_name" --region "$REGION" &> /dev/null; then
        echo "Repository '$repo_name' already exists."
    else
        echo "Creating repository '$repo_name'..."
        aws ecr create-repository --repository-name "$repo_name" --region "$REGION" > /dev/null
        echo "Repository '$repo_name' created successfully."
    fi
}

pull_helm_chart() {
    local repo_url="$1"
    local dest_dir="${2:-$DEFAULT_CHART_DIR}"

    if [[ -z "$repo_url" ]]; then
        echo "Helm repository URL required."
        exit 1
    fi

    mkdir -p "$dest_dir"
    echo "Pulling Helm chart from $repo_url to $dest_dir"
    helm pull "$repo_url" --destination "$dest_dir"
}

push_chart_to_ecr() {
    local chart_path="$1"
    local ecr_repo="$2"

    if [[ -z "$chart_path" || -z "$ecr_repo" ]]; then
        echo "Chart path and ECR repository required."
        exit 1
    fi

    if [[ ! -f "$chart_path" ]]; then
        echo "Chart file not found at $chart_path"
        exit 1
    fi

    auth_ecr
    echo "Pushing Helm chart to ECR repository: $ecr_repo"
    helm push "$chart_path" "oci://${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/$ecr_repo"
    logout_ecr
}

# ------------------------ Command Handler ------------------------

main() {
    case "$1" in
        ecr)
            case "$2" in
                helm-create-repository)
                    auth_ecr
                    create_helm_repo "$3"
                    logout_ecr
                    ;;
                helm-push)
                    push_chart_to_ecr "$3" "$4"
                    ;;
                *)
                    echo "Invalid ecr subcommand"
                    show_help
                    ;;
            esac
            ;;
        helm)
            case "$2" in
                pull)
                    pull_helm_chart "$3" "$4"
                    ;;
                *)
                    echo "Invalid helm subcommand"
                    show_help
                    ;;
            esac
            ;;
        --help|-h)
            show_help
            ;;
        *)
            echo "Unknown command"
            show_help
            ;;
    esac
}

main "$@"
