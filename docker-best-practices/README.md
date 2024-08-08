# Best Practices for Alfresco Containers

This lab provides a series of exercises to apply best practices when deploying Alfresco with containers.

A base Alfresco deployment is provided, which includes the following files:

```
.
├── Dockerfile
├── alfresco-global.properties
└── compose.yaml
```

- **Dockerfile**: A file containing the necessary instructions to build the Alfresco Docker image including Alfresco and Share web applications.
- **alfresco-global.properties**: Configuration properties for Alfresco.
- **compose.yaml**: A Docker Compose file to set up and run the Alfresco containers.

## Overview of Steps

1. Manage container dependencies
2. Limit resource consumption for containers
3. Use volumes for persistent storage
4. Move secrets to an environment file
5. Analyze vulnerabilities

## Prerequisites

Ensure you have Docker and Docker Compose installed on your system. For installation instructions, refer to the [Docker Documentation](https://docs.docker.com/get-docker/).


## 1. Manage container dependencies

### Objective

Ensure the Alfresco container starts only when the PostgreSQL container is ready.

### Steps

1. Modify `compose.yaml` file to add following configuration:

  `postgres`
  - Add a `healthcheck` clause that ensures that the PostgreSQL container is regularly checked for readiness.
    - `test`: This command is used to check the health of the container. `["CMD", "pg_isready"]` uses the `pg_isready` command, which checks the readiness of the PostgreSQL server.
    - `interval`: This sets the interval between each health check attempt. In this case, it is set to 10 seconds, meaning the health check runs every 10 seconds.
    - `timeout`: This specifies the maximum amount of time to wait for the health check command to complete. Here, it is set to 5 seconds.
    - `retries`: This indicates the number of consecutive failures required for the container to be considered unhealthy. With retries set to 5, the container will be marked as unhealthy if the health check fails 5 times in a row.
```  
        healthcheck:
          test: ["CMD", "pg_isready"]
          interval: 10s
          timeout: 5s
          retries: 5
```    

  `alfresco`
  - Add a `depends_on` clause to ensure that the Alfresco container will wait to start until the PostgreSQL container is fully operational and healthy
    - `postgres`: This specifies that the Alfresco service depends on the PostgreSQL service.
    - `condition: service_healthy`: This condition ensures that the Alfresco container will only start if the PostgreSQL container passes its health checks and is considered healthy.
```    
        depends_on: 
          postgres:
            condition: service_healthy
```      

2. Once `compose.yaml` is ready, start the composition using following command:

```
docker compose up
```

3. Verify that `alfresco` container is not started until `postgres` container is ready in the logs.

4. Check the resource usage of each container using the following command:

```
docker stats
NAME        CPU %   MEM USAGE / LIMIT
alfresco    0.77%   842.1MiB  / 19.51GiB
postgres    0.06%    67.1MiB  / 19.51GiB
```

5. Stop Docker Compose before proceeding to the next step by pressing `Ctrl+C` and then entering the following command:

```
docker compose down
```

>> You can compare your `compose.yaml` file with the solution available in the [best-practices/1](https://github.com/aborroy/alfresco-containers/tree/best-practices/1) branch


## 2. Limit resource consumption for containers

### Objective

Ensure containers do not consume resources (CPU and memory) without limits.

### Steps

1. Modify `compose.yaml` file to add following configuration:

  `postgres`
  - Add a `deploy` clause that manages resource allocation by setting both maximum limits and guaranteed reservations for CPU and memory.
    - `limits`: These settings specify the maximum amount of resources the service can use.
      - `cpus: '1'`: Limits the service to use up to 1 CPU. This prevents the container from exceeding this CPU allocation.
      - `memory: 1gb`: Limits the service to use up to 1 gigabyte of memory. The container cannot consume more than this amount of RAM.
    - `reservations`: These settings define the minimum amount of resources guaranteed for the service.
      - `cpus: '0.5'`: Reserves 0.5 CPU for the service. This ensures that at least this amount of CPU is available for the container to use.
      - `memory: 512m`: Reserves 512 megabytes of memory for the service. This guarantees that the container will have at least this amount of RAM available.
```  
        deploy:
          resources:
            limits:
              cpus: '1'
              memory: 1gb
            reservations:
              cpus: '0.5'
              memory: 512m
```    

  `alfresco`
  - Add a `deploy` clause that manages resource allocation by setting both maximum limits and guaranteed reservations for CPU and memory.
    - `limits`: These settings specify the maximum amount of resources the service can use.
      - `cpus: '2'`: Limits the service to use up to 2 CPUs. This prevents the container from exceeding this CPU allocation.
      - `memory: 3gb`: Limits the service to use up to 3 gigabyte of memory. The container cannot consume more than this amount of RAM.
    - `reservations`: These settings define the minimum amount of resources guaranteed for the service.
      - `cpus: '1'`: Reserves 1 CPU for the service. This ensures that at least this amount of CPU is available for the container to use.
      - `memory: 2gb`: Reserves 2 GBs of memory for the service. This guarantees that the container will have at least this amount of RAM available.
```    
        deploy:
          resources:
            limits:
              cpus: '2'
              memory: 3gb
            reservations:
              cpus: '1'
              memory: 2gb
```      

2. Once `compose.yaml` is ready, start the composition using following command:

```
docker compose up
```

3. Check the resource usage of each container using the following command:

```
docker stats
NAME        CPU %   MEM USAGE / LIMIT
alfresco    4.67%   842.1MiB  / 3GiB
postgres    2.06%    67.1MiB  / 1GiB
```

4. Stop Docker Compose before proceeding to the next step by pressing `Ctrl+C` and then entering the following command:

```
docker compose down
```

>> You can compare your `compose.yaml` file with the solution available in the [best-practices/2](https://github.com/aborroy/alfresco-containers/tree/best-practices/2) branch


## 3. Use volumes for persistent storage

### Objective

Ensure container data is persisted in external storage so that it can be reused with the same data even after the container is removed.

### Steps

1. Modify `compose.yaml` file to add following configuration:

  `postgres`
  - Add a `volumes` clause to store container PostgreSQL data folder `/var/lib/postgresql/data` in a Docker volume named `postgres-data`
```  
        volumes:
          - postgres-data:/var/lib/postgresql/data
```    

  `alfresco`
  - Add a `volumes` clause to store container Alfresco data folder `/usr/local/tomcat/alf_data` in a Docker volume named `alf-repo-data`
```    
        volumes:
          - alf-repo-data:/usr/local/alf_data
```

  - Declare both Docker volumes at the same level as the `services` clause in the `compose.yaml` file
```
volumes:
  postgres-data:
  alf-repo-data:
```  

>> Instead of using a Docker native volume, you can use a [Bind Mount](https://docs.docker.com/storage/bind-mounts/). This enables you to mount a file or folder from the host machine directly into the container. Be aware that you might need to adjust permission settings, as the folder will be accessed by the user running the container.

2. Once `compose.yaml` is ready, start the composition using following command:

```
docker compose up
```

3. Verify the volumes have been created:

```
docker volume ls
DRIVER  VOLUME NAME
local   alf-repo-data
local   postgres-data
```

4. Stop Docker Compose before proceeding to the next step by pressing `Ctrl+C` and then entering the following command:

```
docker compose down
```

>> You can compare your `compose.yaml` file with the solution available in the [best-practices/3](https://github.com/aborroy/alfresco-containers/tree/best-practices/3) branch


## 4. Move secrets to an environment file

### Objective

Remove any sensitive information from the `compose.yaml` file to ensure it can be safely shared or published.

### Steps

1. Create an environment file named `.env` with the following content:

```
POSTGRES_PASSWORD=alfresco
POSTGRES_USER=alfresco
POSTGRES_DB=alfresco
PGUSER=alfresco
```

2. Modify `compose.yaml` file to replace sensitive information with variables

  `postgres`
```  
        environment:
            - POSTGRES_PASSWORD=$POSTGRES_PASSWORD
            - POSTGRES_USER=$POSTGRES_USER
            - POSTGRES_DB=$POSTGRES_DB
            - PGUSER=$PGUSER
```    

3. Once `compose.yaml` is ready, start the composition using following command:

```
docker compose up
```

4. Verify the service is running as expected at http://localhost:8080/alfresco with credentials `admin`/`admin`

5. Stop Docker Compose before proceeding to the next step by pressing `Ctrl+C` and then entering the following command:

```
docker compose down
```

>> You can compare your `compose.yaml` file with the solution available in the [best-practices/4](https://github.com/aborroy/alfresco-containers/tree/best-practices/4) branch


## 5. Analyze vulnerabilities

### Objective

Address or reduce vulnerabilities in a Docker image using the `docker scout` tool.

### Steps

1. Build locally the Docker Image that contains the configuration for Alfresco and Share web applications

```
docker build . -t local-alfresco-share
```

2. Use `docker scout` to get a report of critical vulnerabilities

```
docker scout cves --only-severity critical --locations local://local-alfresco-share

   2C     0H     0M     0L  org.postgresql/postgresql 42.6.0
      Affected range : >=42.6.0
                     : <42.6.1
      Fixed version  : 42.7.2, 42.6.1, 42.5.5, 42.4.4, 42.3.9, 42.2.8   
   1C     0H     0M     0L  org.apache.cxf/cxf-core 4.0.2
   1C     0H     0M     0L  org.quartz-scheduler/quartz 2.3.2
   1C     0H     0M     0L  org.apache.cxf/cxf-core 3.4.10
```

3. Update the `Dockerfile` to utilize a newer version of the PostgreSQL library

   - Replace this line...
```
RUN cp /tmp/alfresco/distribution/web-server/lib/postgresql-42.6.0.jar $TOMCAT_DIR/webapps/alfresco/WEB-INF/lib/ 
```  
   - ... with these:
```
RUN curl -L -o /tmp/alfresco/distribution/web-server/lib/postgresql-42.6.1.jar \
    https://repo1.maven.org/maven2/org/postgresql/postgresql/42.6.1/postgresql-42.6.1.jar && \
    cp /tmp/alfresco/distribution/web-server/lib/postgresql-42.6.1.jar $TOMCAT_DIR/webapps/alfresco/WEB-INF/lib/ && \
    rm /tmp/alfresco/distribution/web-server/lib/postgresql-42.6.0.jar
# Remove ZIP Distribution file to avoid false positive in vulnerability scanning
RUN rm -rf /tmp/alfresco/distribution && rm -rf /tmp/alfresco/alfresco-content-services-community-distribution-23.2.1.zip    
```   

4. Build again the Docker Image to apply the changes

```
docker build . -t local-alfresco-share:2.0
```

5. Verify the critical vulnerability has been addressed with `docker scout`


```
docker scout cves --only-severity critical local://local-alfresco-share:2.0
   1C     0H     0M     0L  org.apache.cxf/cxf-core 3.4.10
   1C     0H     0M     0L  org.apache.cxf/cxf-core 4.0.2
   1C     0H     0M     0L  org.quartz-scheduler/quartz 2.3.2
```

6. Stop Docker Compose before proceeding to the next step by pressing `Ctrl+C` and then entering the following command:

```
docker compose down
```

>> You can compare your `compose.yaml` file with the solution available in the [best-practices/5](https://github.com/aborroy/alfresco-containers/tree/best-practices/5) branch