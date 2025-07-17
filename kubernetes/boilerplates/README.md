

Add Dockerhub creds

``` bash

kubectl create secret docker-registry registry-credential --docker-server=docker.io --docker-username=<username> --docker-password=<password> --docker-email=<email>

```

```bash

kubectl create secret tls my-tls-secret \  
--key < private_key_filename> \  
--cert <certificate_filename>

#example

kubectl create secret tls my-tls --key key.pem --cert=full.pem

```


### Use that cert in deployment's

``` yaml

apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: traefik-dashboard
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`traefik.local.rushikesh.de`)
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
  tls:
    secretName: tlssecret # <--- here 

```


#### Delete all pods in namespace

```bash

kubectl delete --all pods --namespace=foo

```

#### Delete all svc and deployments in namespace

```bash

kubectl delete --all svc --namespace=foo
kubectl delete --all deployment --namespace=foo

```

#### Delete all terminating pods 
```bash

k delete pods --field-selector=status.phase=

```
```bash
kubectl exec --stdin --tty <pod> -- /bin/bash

k exec -it <pod> -- /bin/bash

```
### create chart
```bash
helm create <chart_name>
```

### get template
```bash
helm template <chart_dir>
```


## print a join token command to join worker nodes to master node 

``` bash
#command

kubeadm token create --print-join-command

```
* ####  Check labels 
```bash
k get ns default --show-labels
```

* #### Set label
```bash
k label namespace default <key>=<value>
```


### set to Nodeport

```bash
kubectl patch svc you-svc -p '{"spec": {"type": "NodePort"}}'
```

### set external ip

``` bash
 kubectl patch svc frontend -p '{"spec":{"externalIPs":["192.168.0.103"]}}'
```


### on localhost
```bash

kubectl port-forward svc/<svc_name> <port>

kubectl port-forward svc/flask-test-01 9898


```

### on all interfaces 0.0.0.0
```bash

kubectl port-forward svc/<svc_name> <port> --address 0.0.0.0

```


[source](https://stackoverflow.com/posts/67526339/timeline)

You can do this in two ways. Either _imperative_ - a quick command Or _declarative_ - good for a production environment where you store your Deployment-manifest in Git.

**Imperative way**: (this will then diverge from what you have in your yaml-file)

```bash
kubectl scale deployment mage-di --replicas=2
```

**Declarative way**, edit this line in your Yaml file:

```yaml
replicas: 2
```

then apply it to the cluster with:

```bash
kubectl apply -f k8-deployment.yaml
```

See also:

- [Declarative config management](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/declarative-config/)
- [Imperative config management with commands](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/imperative-command/)


```bash

kubectl config set-context --current --namespace=<namespace>


```