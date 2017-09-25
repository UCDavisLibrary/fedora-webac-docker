FROM jetty:9.4.6

RUN apt-get update
RUN apt-get install -y wget unzip
# RUN wget https://github.com/fcrepo4-exts/fcrepo-webapp-plus/releases/download/fcrepo-webapp-plus-4.7.3/fcrepo-webapp-plus-webac-4.7.3.war -O /var/lib/jetty/webapps/fcrepo.war
RUN wget https://github.com/fcrepo4-exts/fcrepo-webapp-plus/releases/download/fcrepo-webapp-plus-4.7.4/fcrepo-webapp-plus-webac-4.7.4.war -O /var/lib/jetty/webapps/fcrepo.war

# HACK for loading spring jars on 'boot'
# crazy docker issue... need to get to the bottom of it.
RUN mkdir -p /var/lib/jetty/lib/ext
RUN unzip /var/lib/jetty/webapps/fcrepo.war -d /tmpfcrepo
RUN cp -r /tmpfcrepo/WEB-INF/lib/spring* /var/lib/jetty/lib/ext/
RUN rm -rf /tmpfcrepo

RUN mkdir -p /fedora-data
RUN chmod -R a+rw /fedora-data

# COPY ./default-repo-config.xml /default-repo-config.xml
COPY ./fcrepo.xml /var/lib/jetty/webapps/fcrepo.xml
COPY ./overlay-web.xml /overlay-web.xml
COPY ./jetty-users.properties /config/file-simple/jetty-users.properties

RUN chown jetty:jetty /var/lib/jetty/webapps/fcrepo.xml
RUN chown jetty:jetty /overlay-web.xml
RUN chown jetty:jetty /var/lib/jetty/webapps/fcrepo.war

ENV JAVA_OPTS="-Dfile.encoding=UTF-8 \
    -Dfcrepo.home=/fedora-data \
    -Dfcrepo.modeshape.configuration=classpath:/config/servlet-auth/repository.json" 

CMD chown -R jetty:jetty /fedora-data && java $JAVA_OPTS -jar "$JETTY_HOME/start.jar"