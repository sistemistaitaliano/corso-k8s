#!/bin/bash

NAMESPACE=default
CLUSTER_NAME=my-db
MANIFEST=postgres.yaml

echo "=== Eliminazione cluster PostgreSQL esistente ==="
kubectl delete postgresql $CLUSTER_NAME -n $NAMESPACE --ignore-not-found

echo "=== Eliminazione PVC associati ==="
kubectl get pvc -n $NAMESPACE | grep pgdata-$CLUSTER_NAME | awk '{print $1}' | xargs -r kubectl delete pvc -n $NAMESPACE

echo "=== Eliminazione secret associati ==="
kubectl get secret -n $NAMESPACE | grep $CLUSTER_NAME | awk '{print $1}' | xargs -r kubectl delete secret -n $NAMESPACE

echo "=== Imposta NFS come storage class di default ==="
kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "=== Applicazione del manifest del cluster ==="
kubectl apply -f $MANIFEST

echo "=== Attendere che tutti i pod siano Running e Ready ==="
kubectl get pods -n $NAMESPACE -w

