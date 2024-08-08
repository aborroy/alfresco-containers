# Alfresco Containers - Docker Image Building

## Overview

This project contains the necessary files and instructions to build a custom Docker Image for Alfresco.

## Repository Structure

The repository is organized into the following structure:

```
.
├── Dockerfile
├── alfresco-global.properties
└── compose.yaml
```

### Files and Directories

- **Dockerfile**: A file containing the necessary instructions to build the Alfresco Docker image including Alfresco and Share web applications. This `Dockerfile` is following the same approach described in the script [06-install_alfresco.sh](https://github.com/aborroy/alfresco-ubuntu-installer/blob/main/scripts/06-install_alfresco.sh), that provides instructions to install Alfresco in Ubuntu from ZIP Distribution files.
- **alfresco-global.properties**: Configuration properties for Alfresco.
- **compose.yaml**: A Docker Compose file to set up and run the Alfresco containers.

## Prerequisites

Ensure you have the following installed on your machine:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

## Instructions

### Cloning the Repository

Clone the repository to your local machine using the following command:

```sh
git clone https://github.com/aborroy/alfresco-containers.git
cd alfresco-containers/docker-image-building
```

### Building the Docker Image

To build the Alfresco Docker image, execute the following command:

```sh
docker build . -t custom-alfresco-share
```

Although this step is not required for the Docker Compose deployment, it allows you to build the Docker image so that it can be run as a single container using the `docker run` command:

```sh
docker run -p 8080:8080 custom-alfresco-share
```

### Running Alfresco with Docker Compose

To start Alfresco using Docker Compose, run the following command:

```sh
docker compose up
```

This command will read the `compose.yaml` file, build the `Dockerfile` and start the necessary containers for Alfresco.

Once the deployment is up & ready Alfresco Platform will be available with default credentials `admin`/`admin` in following endpoints:

* Repository: http://localhost:8080/alfresco
* Share UI: http://localhost:8080/share


### Configuration

The main configuration file is `alfresco-global.properties`, which contains key settings for your Alfresco instance.

### Stopping the Containers

To stop the running containers, use:

```sh
docker compose down
```