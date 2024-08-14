# Deploying Alfresco on Kubernetes with Helm

This guide provides a comprehensive walkthrough for deploying Alfresco Community Edition on Kubernetes using Helm, ensuring a streamlined and customizable deployment process.

## Step-by-Step Overview

1. **Create Namespace**
2. **Install Ingress-NGINX**
3. **Deploy Alfresco**
4. **Clean Up Resources**
5. **Customize Your Deployment**

## Prerequisites

Before starting, ensure the following tools are installed and properly configured on your system:

- **Docker and Docker Compose**: Follow the [Docker Installation Guide](https://docs.docker.com/get-docker/). After installation, adjust Docker Desktop settings as follows:
  - **Resources**: `CPUs: 8`, `Memory: 16GB`, `Swap: 1GB`
  - **Kubernetes**: Enable Kubernetes under `Settings > Kubernetes`.

- **Helm**: Install Helm by following the [Helm Installation Guide](https://helm.sh/docs/intro/install/).

- **Kubectl**: Install Kubectl as per the [Kubernetes Documentation](https://kubernetes.io/docs/tasks/tools/).

- **Optional**: You can manage your Kubernetes cluster using the [Lens Desktop Application](https://k8slens.dev). Set it up by following the [Getting Started Guide](https://docs.k8slens.dev/v4.0.3/getting-started).


## 1. Create a Namespace

### Objective

Establish an isolated environment within the Kubernetes cluster for Alfresco.

### Steps

1. Set `kubectl` to use Docker Desktop's Kubernetes context:

   ```sh
   kubectl config use-context docker-desktop
   ```

2. Create a new namespace for Alfresco:

   ```sh
   kubectl create namespace alfresco
   ```

3. Verify the namespace creation:

   ```sh
   kubectl get namespaces
   ```

   The `alfresco` namespace should be listed as Active.


## 2. Install Ingress-NGINX

### Objective

Set up an Ingress controller to manage internal and external communications for the Kubernetes cluster.

### Steps

1. Install the Ingress-NGINX controller using Helm:

   ```sh
   helm upgrade --install ingress-nginx ingress-nginx \
   --repo https://kubernetes.github.io/ingress-nginx \
   --namespace ingress-nginx --create-namespace
   ```

2. Confirm the installation by checking the status of the namespace and pods:

   ```sh
   kubectl get namespaces
   ```

   ```sh
   kubectl get pods -n ingress-nginx
   ```

3. Enable snippet annotations required for Alfresco Search Services:

   ```sh
   kubectl -n ingress-nginx patch cm ingress-nginx-controller \
   -p '{"data": {"allow-snippet-annotations":"true"}}'
   ```

4. Wait for the controller to restart with the new settings:

   ```sh
   kubectl wait --namespace ingress-nginx \
   --for=condition=ready pod \
   --selector=app.kubernetes.io/component=controller \
   --timeout=90s
   ```


## 3. Deploy Alfresco

### Objective

Deploy Alfresco Community Edition on your Kubernetes cluster.

### Steps

1. Add the Alfresco Helm chart repository and update your Helm repo:

   ```sh
   helm repo add alfresco https://kubernetes-charts.alfresco.com/stable
   helm repo update
   ```

2. Download the community values file for the Alfresco Helm chart:

   ```sh
   wget https://raw.githubusercontent.com/Alfresco/acs-deployment/master/helm/alfresco-content-services/community_values.yaml
   ```

3. Install Alfresco using Helm, providing a `sharedSecret` for secure communication:

   ```sh
   helm install acs alfresco/alfresco-content-services \
     --values=community_values.yaml \
     --set global.search.sharedSecret=$(openssl rand -hex 24) \
     --atomic \
     --timeout 10m0s \
     --namespace=alfresco
   ```

   > Monitor the deployment using **Lens** or `kubectl`.

4. Once deployment is complete, access Alfresco services:

   - Repository: https://localhost/alfresco
   - Share: https://localhost/share
   - API Explorer: https://localhost/api-explorer


## 4. Clean Up Resources

### Objective

Remove all Kubernetes resources associated with the Alfresco deployment.

### Steps

1. Uninstall the Alfresco deployment:

   ```sh
   helm uninstall -n alfresco acs
   ```

2. Uninstall Ingress-NGINX:

   ```sh
   helm uninstall -n ingress-nginx ingress-nginx
   ```

3. Delete the Alfresco namespace:

   ```sh
   kubectl delete namespace alfresco
   ```

4. Delete the Ingress-NGINX namespace:

   ```sh
   kubectl delete namespace ingress-nginx
   ```

   > Verify resource cleanup using **Lens** or `kubectl`.


## 5. Customize Your Deployment

### Objective

Create a tailored deployment of Alfresco Community on Kubernetes.

### Steps

A sample customization is provided in the `customized-deployment` folder:

```
tree
.
├── custom
│   ├── Chart.yaml
│   └── templates
│       └── configmap-repo.yaml
├── start.sh
├── stop.sh
└── values
    └── community_values.yaml
```

- The `custom` folder contains a Helm chart for a custom ConfigMap for the Alfresco Repository.
- The `values` folder contains a modified `community_values.yaml` file to address Transform Core AIO issues and to deploy ACA UI.
- Use `start.sh` and `stop.sh` scripts to manage deployment.

1. Start the customized deployment:

   ```sh
   ./start.sh
   ```

   > Monitor progress using **Lens** or `kubectl`.

2. Access the customized Alfresco services:

   - Repository: https://localhost/alfresco
   - Share: https://localhost/share
   - API Explorer: https://localhost/api-explorer
   - ACA UI: https://localhost/workspace

3. To remove resources, execute:

   ```sh
   ./stop.sh
   ```

## Troubleshooting

### Lens

Use the [Lens](https://k8slens.dev) desktop application for easy troubleshooting. Set it up via the [Getting Started Guide](https://docs.k8slens.dev/v4.0.3/getting-started).

### Kubernetes Dashboard

Alternatively, you can use the Kubernetes Dashboard:

1. Retrieve the service account token:

   ```bash
   kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
   ```

2. Start the Kubernetes proxy:

   ```bash
   kubectl proxy &
   ```

3. Open the Kubernetes Dashboard at `http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login`.

4. Log in using the token retrieved earlier, select the `alfresco` namespace, and explore the deployment.