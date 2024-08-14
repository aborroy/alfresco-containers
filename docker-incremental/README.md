# Incremental Alfresco deployment for Docker Compose

This lab provides a series of exercises to incrementally deploy Alfresco, starting with a minimal configuration and progressing to more complex setups. Each step builds on the previous one to add more features and capabilities.

## Overview of Steps

1. Repository with REST API
2. Repository with REST API and metadata search
3. Repository with REST API, metadata search, transformations and content search
4. Repository with REST API, metadata search, transformations, content search and messaging
5. Repository with REST API, metadata search, transformations, content search, messaging and UI

## Prerequisites

Ensure you have Docker and Docker Compose installed on your system. For installation instructions, refer to the [Docker Documentation](https://docs.docker.com/get-docker/).


## 1. Repository with REST API

### Objective

Deploy Alfresco with a minimal setup, featuring only the core repository with REST API access.

### Steps

1. Create a `compose.yaml` file with the following services:

  `alfresco`
  - Image name: `alfresco/alfresco-content-repository-community:23.2.1`
  - Environment variables:
    - `JAVA_TOOL_OPTIONS` with metadata encryption properties. Refer to (community-docker-compose.yml)[https://github.com/Alfresco/acs-deployment/blob/v8.3.0/docker-compose/community-docker-compose.yml#L18]
    - `JAVA_OPTS` includes following values for [alfresco-global.properties](https://github.com/Alfresco/alfresco-community-repo/blob/23.2.2.3/repository/src/main/resources/alfresco/repository.properties). Only database connection values are enabled, while connections for searching, transformation, and messaging are disabled. In addition CSRF filter is disabled to allow connections from Alfresco Repository Web Console.
```    
      db.driver=org.postgresql.Driver
      db.username=alfresco
      db.password=alfresco
      db.url=jdbc:postgresql://postgres:5432/alfresco
      index.subsystem.name=noindex
      local.transform.service.enabled=false
      repo.event2.enabled=false
      messaging.subsystem.autoStart=false      
      csrf.filter.enabled=false 
```      
  - Ports: Map container port 8080 to local port 8080

  `postgres`
  - Image name: `postgres:14.4`
  - Environment variables:
```  
    POSTGRES_PASSWORD=alfresco
    POSTGRES_USER=alfresco
    POSTGRES_DB=alfresco
```    
  - Overwrite Docker Image starting command with `postgres -c max_connections=300 -c log_min_messages=LOG`

2. Once `compose.yaml` is ready, start the composition using following command:

```
docker compose up
```

3. Verify that repository is up and ready accessing to http://localhost:8080/alfresco using web browser and default credentials `admin`/`admin`

4. Stop Docker Compose before proceeding to the next step by pressing `Ctrl+C` and then entering the following command:

```
docker compose down
```

>> You can compare your `compose.yaml` file with the solution available in the [incremental/1](https://github.com/aborroy/alfresco-containers/tree/incremental/1/docker-incremental) branch


## 2. Repository with REST API and metadata search

### Objective

Enhance the deployment to include metadata search capabilities using Alfresco Search Services.

### Steps

1. Modify the `compose.yaml` file to add indexing and searching metadata feature:

  `alfresco`
  - Modify environment variables:
    - Modify `JAVA_OPTS` to replace `index.subsystem.name=noindex` by the following lines, that enable Search Service using `secret` communication mode:
```
      index.subsystem.name=solr6
      solr.host=solr6
      solr.secureComms=secret
      solr.sharedSecret=secret
```
  Add Search Service named as `solr6` to `compose.yaml` file
  - Image name: `alfresco/alfresco-search-services:2.0.11`
  - Environment variables:
```
    SOLR_ALFRESCO_HOST=alfresco
    SOLR_ALFRESCO_PORT=8080
    SOLR_CREATE_ALFRESCO_DEFAULTS=alfresco
    ALFRESCO_SECURE_COMMS=secret
    JAVA_TOOL_OPTIONS=-Dalfresco.secureComms.secret=secret
```

2. Once `compose.yaml` is ready, start the composition using following command:

```
docker compose up
```

3. Verify
* Access the repository at http://localhost:8080/alfresco using `admin`/`admin`
* Test metadata search using the `fts-alfresco` search syntax to query for term `budget`

4. Stop Docker Compose before proceeding to the next step by pressing `Ctrl+C` and then entering the following command:

```
docker compose down
```

>> You can compare your `compose.yaml` file with the solution available in the [incremental/2](https://github.com/aborroy/alfresco-containers/tree/incremental/2/docker-incremental) branch


## 3. Repository with REST API, transformations, metadata search and content search

### Objective

Expand the deployment to include content transformation capabilities, enabling full content search.

### Steps

1. Update the `compose.yaml` file to include a transformation feature that also enables content searching:

`alfresco`
  - Modify environment variables:
    - Modify `JAVA_OPTS` to replace `local.transform.service.enabled=false` by the following line, that enables Transform service:
```
    localTransform.core-aio.url=http://transform-core-aio:8090/
```
Add Transform Service named as `transform-core-aio` to `compose.yaml` file
  - Image name: `alfresco/alfresco-transform-core-aio:5.1.3`

2. Once `compose.yaml` is ready, start the composition using following command:

```
docker compose up
```

3. Verify
* Access the repository at  http://localhost:8080/alfresco using `admin`/`admin`
* Test metadata search using the `fts-alfresco` search syntax to query for term `budget`
* Test content search and transformation with the term `beecher`

4. Stop Docker Compose before proceeding to the next step by pressing `Ctrl+C` and then entering the following command:

```
docker compose down
```

>> You can compare your `compose.yaml` file with the solution available in the [incremental/3](https://github.com/aborroy/alfresco-containers/tree/incremental/3/docker-incremental) branch


## 4. Repository with REST API, transformations, metadata search, content search and messaging

### Objective

Enable messaging capabilities by integrating ActiveMQ with the deployment.

### Steps

1. Update the `compose.yaml` file to include a connection to ActiveMQ that also enables messaging service:

`alfresco`
  - Modify environment variables:
    - Modify `JAVA_OPTS` to replace `repo.event2.enabled=false` and `messaging.subsystem.autoStart=false` lines by the following one, that enables Messaging service:
```
    messaging.broker.url=nio://activemq:61616
```
Add ActiveMQ Service named as `activemq` to `compose.yaml` file
  - Image name: `alfresco/alfresco-activemq:5.18-jre17-rockylinux8`
  - Map container port 8161 to local port 8161

2. Once `compose.yaml` is ready, start the composition using following command:

```
docker compose up
```

3. Verify
* Access the repository at http://localhost:8080/alfresco using `admin`/`admin`
* Test metadata search with the term `budget` 
* Test content search and transformation with the term `beecher`
* Verify messaging service functionality via the ActiveMQ Web Console at http://localhost:8161/admin/topics.jsp using `admin`/`admin`

4. Stop Docker Compose before proceeding to the next step by pressing `Ctrl+C` and then entering the following command:

```
docker compose down
```

>> You can compare your `compose.yaml` file with the solution available in the [incremental/4](https://github.com/aborroy/alfresco-containers/tree/incremental/4/docker-incremental) branch


## 5. Repository with REST API, transformations, metadata search, content search, messaging and UI

### Objective

Complete the deployment by adding the Content App UI and a Web Proxy (NGINX) to serve the UI and other services

### Steps

1. Update the `compose.yaml` file to include the Content App UI and a Web Proxy (Nginx) that serves both the Content App and other services:

`alfresco`
  - Remove mapping for port 8080, as it will be replaced by the Web Proxy service
Add ADF UI named as `content-app`  to `compose.yaml` file
  - Image name: `alfresco/alfresco-content-app:4.4.1`
Add Share UI named as `share` to `compose.yaml` file
  - Image name: `alfresco/alfresco-share:23.2.1`
  - Environment variables:
```
    REPO_HOST=alfresco
```  
Add Web Proxy NGINX named as `proxy` to `compose.yaml` file
  - Image name: `alfresco/alfresco-acs-nginx:3.4.2`
  - Environment variables:
```
    DISABLE_PROMETHEUS=true
    DISABLE_SYNCSERVICE=true
    DISABLE_ADW=true
    DISABLE_CONTROL_CENTER=true
    ENABLE_CONTENT_APP=true
```
  - Set the dependency for the `alfresco` and `content-app` services
  - Map container port 8080 to local port 8080  

2. Once `compose.yaml` is ready, start the composition using following command:

```
docker compose up
```

3. Verify
* Access the repository at http://localhost:8080/alfresco using `admin`/`admin`
* Test metadata search with the term `budget` 
* Test content search and transformation with the term `beecher`
* Verify messaging service functionality via the ActiveMQ Web Console at http://localhost:8161/admin/topics.jsp using `admin`/`admin`
* Access the Content App UI at http://localhost:8080/content-app using `admin`/`admin`
* Access the Share App UI at http://localhost:8080/share using `admin`/`admin`

>> You can compare your `compose.yaml` file with the solution available in the [incremental/5](https://github.com/aborroy/alfresco-containers/tree/incremental/5/docker-incremental) branch