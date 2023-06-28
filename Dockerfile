ARG IMAGE=intersystemsdc/iris-community:2020.3.0.221.0-zpm
ARG IMAGE=intersystemsdc/iris-community:2020.4.0.524.0-zpm
ARG IMAGE=intersystemsdc/iris-community
FROM $IMAGE



USER root   


## Embedded Python environment

ENV IRISUSERNAME "_SYSTEM"

ENV IRISPASSWORD "SYS"

ENV IRISNAMESPACE "USER"

ENV PYTHON_PATH=/usr/irissys/bin/

ENV PATH "/usr/irissys/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/irisowner/bin"

WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp

## Install Node.js and Newman
RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g newman && \
    npm install -g newman-reporter-htmlextra



USER ${ISC_PACKAGE_MGRUSER}


COPY  src src
COPY module.xml module.xml
COPY iris.script /tmp/iris.script
COPY src/web/index.html /usr/irissys/csp/user/index.html


RUN iris start IRIS \
	&& iris session IRIS < /tmp/iris.script \
    && iris stop IRIS quietly
    

