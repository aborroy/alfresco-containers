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

To verify the Alfresco Docker Image follows [best practices](https://docs.docker.com/reference/build-checks/), run this command:

```sh
docker build . --check
Check complete, no warnings found.
```

Once the checking has passed successfully, build the Alfresco Docker image, execute the following command:

```sh
docker build . -t custom-alfresco-share
```

Although this step is not required for the Docker Compose deployment, it allows you to build the Docker image so that it can be run as a single container using the `docker run` command:

```sh
docker run -p 8080:8080 custom-alfresco-share
```

Docker Image `custom-alfresco-share` has been pushed to local Docker Registry:

```sh
docker image ls custom-alfresco-share
custom-alfresco-share   latest    f27abc5c598f   2.63GB
```

### Minimizing Docker Image Size

To reduce the size of a Docker image, you can use a [multi-stage build](https://docs.docker.com/build/building/multi-stage/). This approach involves creating a temporary Docker image to *build* or *download* necessary content, which is then copied into the final Docker image. As a result, all temporary files and layers from the build stage are excluded from the final image.

In this directory, there is a Docker file named `Dockerfile-multistage` that uses an initial stage called `rockylinux9` to download and unzip all the content from the Alfresco distribution. The final Docker image copies these files using `COPY --from=rockylinux9`.

To build this Docker image, tagged as version 2.0, run the following command:

```sh
docker build . -f Dockerfile-multistage -t custom-alfresco-share:2.0
```

You can verify the reduction in Docker image size with:

```sh
docker image ls custom-alfresco-share:2.0
custom-alfresco-share   2.0       cb98a43fddf5   2.11GB
```

This method saves about 0.5 GB of storage, which can improve performance in various processes, such as downloading and running the image.

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