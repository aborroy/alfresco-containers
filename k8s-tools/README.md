# Alfresco k8s Tools

This repository provides links and brief descriptions for a suite of tools that facilitate the installation, deployment, and customization of Alfresco using Helm. These tools are useful for setting up both community and enterprise versions of Alfresco and can be extended or customized to meet specific project requirements.

## Available Tools

### 1. [alf-k8s](https://github.com/aborroy/alf-k8s)

This repository provides Helm templates and initialization scripts that can be used as a starting point for creating custom Kubernetes deployments for Alfresco.

- **Features:**
  - Override default values for repository properties
  - Deploy additional services, like [Alfresco Content App](https://github.com/alfresco/alfresco-content-app)
  - Deploy different Alfresco versions, like 23.2 or 23.1
  - Establish resources consumption limits for `cpu`, `memory` and `replicas`
  - Allow plain HTTP ingress endpoints for testing purposes
  - Deploy to Docker Desktop or [KinD](https://kind.sigs.k8s.io)


### 2. [Alfresco Helm Charts](https://alfresco.github.io/alfresco-helm-charts/index.html)

Alfresco Helm Charts documentation.

- **Features:**
  - Building custom Helm charts
  - Alfresco charts reference
  - Tailoring Alfresco Helm charts

### 3. [Alfresco Helm Examples](https://alfresco.github.io/acs-deployment/docs/helm-examples.html)

Set of Helm Charts to deploy Alfresco in different use cases

- **Features:**
  - Deployment with AWS
  - Deploy Intelligence Services
  - Use of Keycloak
  - Search Service deployment