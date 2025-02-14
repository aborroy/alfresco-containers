FROM alfresco/alfresco-base-tomcat:tomcat10-jre17-rockylinux9

# Default user and group are used to setup permissions for Tomcat process
ARG GROUPNAME=tomcat
ARG USERNAME=tomcat
ARG TOMCAT_DIR=/usr/local/tomcat

# Create support folders and configuration in Tomcat
RUN mkdir -p $TOMCAT_DIR/shared/classes && mkdir -p $TOMCAT_DIR/shared/lib && \
    sed -i 's|^shared.loader=$|shared.loader=${catalina.base}/shared/classes,${catalina.base}/shared/lib/*.jar|' $TOMCAT_DIR/conf/catalina.properties

# Tomcat user does not have permissions to modify webapps or configuration. Switch to root.
# The access will be fixed after all operations are done.
USER root

# Install zip command
RUN yum install -y zip && yum clean all

# Download and unzip Alfresco ZIP Distribution File
RUN mkdir /tmp/alfresco && mkdir /tmp/alfresco/distribution && \
    curl -L -o /tmp/alfresco/alfresco-content-services-community-distribution-23.2.1.zip \
    https://nexus.alfresco.com/nexus/repository/releases/org/alfresco/alfresco-content-services-community-distribution/23.2.1/alfresco-content-services-community-distribution-23.2.1.zip && \
    unzip /tmp/alfresco/alfresco-content-services-community-distribution-23.2.1.zip -d /tmp/alfresco/distribution

# Configure JAR Addons deployment
RUN mkdir -p /usr/local/modules/platform && mkdir -p /usr/local/modules/share && mkdir -p $TOMCAT_DIR/conf/Catalina/localhost && \
    cp /tmp/alfresco/distribution/web-server/conf/Catalina/localhost/* $TOMCAT_DIR/conf/Catalina/localhost/ && \
    echo '<Context></Context>' > $TOMCAT_DIR/conf/Catalina/localhost/ROOT.xml

# Install Web Applications
RUN cp /tmp/alfresco/distribution/web-server/webapps/* $TOMCAT_DIR/webapps/

# Apply configuration
RUN cp -r /tmp/alfresco/distribution/web-server/shared/classes/* $TOMCAT_DIR/shared/classes/ && \
    mkdir /usr/local/keystore && cp -r /tmp/alfresco/distribution/keystore/* /usr/local/keystore/ && \
    mkdir /usr/local/alf_data

# Copy Alfresco global properties
COPY alfresco-global.properties $TOMCAT_DIR/shared/classes/alfresco-global.properties

# Apply AMPs
RUN mkdir /usr/local/amps && cp -r /tmp/alfresco/distribution/amps/* /usr/local/amps/ && \
    cp -r /tmp/alfresco/distribution/bin/* /usr/local/bin/ && \
    java -jar /usr/local/bin/alfresco-mmt.jar install /usr/local/amps $TOMCAT_DIR/webapps/alfresco.war -directory && \
    java -jar /usr/local/bin/alfresco-mmt.jar list $TOMCAT_DIR/webapps/alfresco.war

# Modify alfresco and share logs directory
RUN mkdir $TOMCAT_DIR/webapps/alfresco && unzip $TOMCAT_DIR/webapps/alfresco.war -d $TOMCAT_DIR/webapps/alfresco && \
    mkdir $TOMCAT_DIR/webapps/share && unzip $TOMCAT_DIR/webapps/share.war -d $TOMCAT_DIR/webapps/share && \
    sed -i 's|^appender\.rolling\.fileName=alfresco\.log|appender.rolling.fileName=/usr/local/tomcat/logs/alfresco.log|' /usr/local/tomcat/webapps/alfresco/WEB-INF/classes/log4j2.properties && \
    sed -i 's|^appender\.rolling\.fileName=share\.log|appender.rolling.fileName=/usr/local/tomcat/logs/share.log|' /usr/local/tomcat/webapps/share/WEB-INF/classes/log4j2.properties

# Copy JDBC driver directly to alfresco webapp to avoid setting specific policy for "tomcat/shared/lib"
RUN cp /tmp/alfresco/distribution/web-server/lib/postgresql-42.6.0.jar $TOMCAT_DIR/webapps/alfresco/WEB-INF/lib/

# All files in the tomcat folder must be owned by tomcat user
RUN chgrp -R ${GROUPNAME} ${TOMCAT_DIR}/webapps && \
    chgrp -R ${GROUPNAME} /usr/local/alf_data && \
    chmod -R g+rwx /usr/local/keystore && \
    chgrp -R ${GROUPNAME} /usr/local/keystore && \
    chmod -R g+rwx /usr/local/alf_data && \
    find ${TOMCAT_DIR}/webapps -type d -exec chmod 0750 {} \; && \
    find ${TOMCAT_DIR}/webapps -type f -exec chmod 0640 {} \; && \
    chmod -R g+r ${TOMCAT_DIR}/webapps && \
    chgrp -R ${GROUPNAME} ${TOMCAT_DIR}

# Grant all security permissions to alfresco and share webapp because of numerous permissions required in order to work properly.
# Grant only deployXmlPermission to ROOT webapp.
RUN  sed -i -e "\$a\grant\ codeBase\ \"file:\$\{catalina.base\}\/webapps\/alfresco\/-\" \{\n\    permission\ java.security.AllPermission\;\n\};\ngrant\ codeBase\ \"file:\$\{catalina.base\}\/webapps\/share\/-\" \{\n\    permission\ java.security.AllPermission\;\n\};\ngrant\ codeBase\ \"file:\$\{catalina.base\}\/webapps\/_vti_bin\/-\" \{\n\    permission\ java.security.AllPermission\;\n\};\ngrant\ codeBase\ \"file:\$\{catalina.base\}\/webapps\/ROOT\/-\" \{\n\    permission org.apache.catalina.security.DeployXmlPermission \"ROOT\";\n\};" ${TOMCAT_DIR}/conf/catalina.policy

# Set the JAVA_TOOL_OPTIONS for metadata encryption
ENV JAVA_TOOL_OPTIONS="\
    -Dencryption.keystore.type=JCEKS \
    -Dencryption.cipherAlgorithm=DESede/CBC/PKCS5Padding \
    -Dencryption.keyAlgorithm=DESede \
    -Dencryption.keystore.location=/usr/local/keystore/metadata-keystore/keystore \
    -Dmetadata-keystore.password=mp6yc0UD9e \
    -Dmetadata-keystore.aliases=metadata \
    -Dmetadata-keystore.metadata.password=oKIWzVdEdA \
    -Dmetadata-keystore.metadata.algorithm=DESede"

# Switching back to tomcat user after having added files to run the container as non-root
USER ${USERNAME}    