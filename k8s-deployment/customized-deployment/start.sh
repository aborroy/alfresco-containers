#!/bin/bash

set -o errexit
set -o pipefail

# Check dependencies
array=( "helm" "kubectl" )
for i in "${array[@]}"
do
    command -v $i >/dev/null 2>&1 || {
        echo >&2 "$i is required";
        exit 1;
    }
done

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace

kubectl -n ingress-nginx patch cm ingress-nginx-controller \
  -p '{"data": {"allow-snippet-annotations":"true"}}'

kubectl -n ingress-nginx rollout status deployment ingress-nginx-controller --timeout=90s

kubectl create namespace alfresco

helm repo add alfresco https://kubernetes-charts.alfresco.com/stable
helm repo update

# Add custom configuration for the Alfresco Config Map
helm install --namespace alfresco alfresco-config ./custom

# Install Alfresco using custom community_values and environment variables
GLOBAL_KNOWN_URLS=https://localhost
VALUES="values/community_values.yaml"
helm install acs alfresco/alfresco-content-services \
   --values=${VALUES} \
   --set global.search.sharedSecret=jTHSDuF6B8Q7L9iTobNpzg3D \
   --set global.known_urls=${GLOBAL_KNOWN_URLS} \
   --atomic \
   --timeout 10m0s \
   --namespace=alfresco
