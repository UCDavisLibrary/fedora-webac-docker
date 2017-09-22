FROM jetty:9.4.6

RUN apt-get update
RUN apt-get install -y wget
RUN wget https://github.com/fcrepo4-exts/fcrepo-webapp-plus/releases/download/fcrepo-webapp-plus-4.7.3/fcrepo-webapp-plus-webac-4.7.3.war -O /var/lib/jetty/webapps/fcrepo.war

COPY ./fcrepo.xml /var/lib/jetty/webapps/fcrepo.xml
COPY ./overlay-web.xml /overlay-web.xml
COPY ./repository.json /config/file-simple/repository.json
COPY ./repo.xml /config/file-simple/repo.xml
COPY ./jetty-users.properties /config/file-simple/jetty-users.properties

ENV JAVA_OPTS="-Dfile.encoding=UTF-8 \
    -Dfcrepo.home=/fedora-data \
    -Dfcrepo.modeshape.configuration=file:/config/file-simple/repository.json \
    -Dfcrepo.modeshape.index.directory=modeshape.index \
    -Dfcrepo.binary.directory=binary.store \
    -Dfcrepo.activemq.directory=activemq \
    -Dcom.arjuna.ats.arjuna.common.ObjectStoreEnvironmentBean.default.objectStoreDir=arjuna.common.object.store \
    -Dcom.arjuna.ats.arjuna.objectstore.objectStoreDir=arjuna.object.store \
    -Dnet.sf.ehcache.skipUpdateCheck=true \
    -Dfcrepo.audit.container=/audit \
    -XX:+UseConcMarkSweepGC \    
    -XX:+CMSClassUnloadingEnabled \ 
    -XX:ConcGCThreads=5 \
    -XX:MaxGCPauseMillis=200 \
    -XX:ParallelGCThreads=20 \
    -XX:MaxMetaspaceSize=512M \
    -Xms1024m \          
    -Xmx2048m" 

CMD chown -R jetty:root /fedora-data && java $JAVA_OPTS -jar "$JETTY_HOME/start.jar"