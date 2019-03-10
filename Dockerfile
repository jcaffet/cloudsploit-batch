FROM amazonlinux:latest
RUN yum -y install which unzip aws-cli jq tar gzip

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 10.15.3

# Install nvm with node and npm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash \
    && source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN node --version

ADD ./scans /scans

RUN cd /scans && \
    npm install 

ADD docker-entrypoint.sh /scans/docker-entrypoint.sh
RUN chmod 744 /scans/docker-entrypoint.sh
WORKDIR /scans
ENTRYPOINT ["/scans/docker-entrypoint.sh"]

