ARG NODE_VERSION=12.18.3
FROM node:${NODE_VERSION}-alpine
RUN apk add --no-cache make pkgconfig gcc g++ python libx11-dev libxkbfile-dev git
ARG version=latest
WORKDIR /home/theia
ADD $version.package.json ./package.json
ARG GITHUB_TOKEN
RUN yarn --pure-lockfile && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
    yarn theia download:plugins && \
    yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

FROM node:${NODE_VERSION}-alpine
# See : https://github.com/theia-ide/theia-apps/issues/34
RUN addgroup theia && \
    adduser -G theia -s /bin/sh -D theia;

RUN chmod g+rw /home && \
    mkdir -p /home/project

RUN apk add --no-cache git openssh bash
ENV HOME /home/theia
WORKDIR /home/theia
COPY --from=0 --chown=theia:theia /home/theia /home/theia
EXPOSE 3000
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins
ENV USE_LOCAL_GIT true

RUN mkdir /home/ressources && \
    cd /home/ressources && \
    echo "cd /home/project && git clone https://github.com/ConfigUrHouse/configurhouse.git && git clone https://github.com/ConfigUrHouse/configurhouse-api.git && cd configurhouse && yarn install && cd ../configurhouse-api && yarn install" > fetch.sh && \
    cd /home/project
EXPOSE 8083
EXPOSE 8084

RUN chown -R theia:theia /home/theia && \
    chown -R theia:theia /home/ressources && \
    chown -R theia:theia /home/project

USER theia
ENTRYPOINT [ "node", "/home/theia/src-gen/backend/main.js", "/home/project", "--hostname=0.0.0.0" ]