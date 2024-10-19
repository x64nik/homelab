#!/bin/bash
read -p "TEMPLATE_ID: " TEMPLATE_ID
read -e -p "QCOW_PATH: " QCOW_PATH
read -p "TEMPLATE_NAME: " TEMPLATE_NAME
read -p "CORES: " CORES
read -p "MEMORY [default: 4096]: " MEMORY
MEMORY=${MEMORY:-4096}


qm create $TEMPLATE_ID --memory $MEMORY --core $CORES --sockets 2 --name $TEMPLATE_NAME --net0 virtio,bridge=vmbr0
qm disk import $TEMPLATE_ID $QCOW_PATH local-zfs
qm set $TEMPLATE_ID --scsihw virtio-scsi-pci --scsi0 local-zfs:vm-$TEMPLATE_ID-disk-0
qm set $TEMPLATE_ID --ide2 local-zfs:cloudinit
qm set $TEMPLATE_ID --boot c --bootdisk scsi0
qm template $TEMPLATE_ID

echo "done ;)"
