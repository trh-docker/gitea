FROM quay.io/spivegin/golangnodesj AS dev-build
WORKDIR /opt/src/src/code.gitea.io/
ADD Makefile /opt/Makefile
RUN apt-get update && apt-get install -y zip libpam0g-dev 
# git clone https://github.com/go-gitea/gitea.git &&\

RUN git clone https://github.com/go-gitea/gitea.git &&\
    cd gitea && cp /opt/Makefile . &&\
    npm install -g less &&\
    make build

FROM debian:stretch-slim
RUN mkdir -p /opt/bin/ 
COPY --from=dev-build /opt/src/src/code.gitea.io/gitea/gitea /opt/bin/gitea
# COPY --from=dev-build /opt/gogs /opt/
WORKDIR /opt/gitea
ADD entry.sh /opt/bin/
RUN chmod +x /opt/bin/entry.sh && chmod +x /opt/bin/gitea &&\
    apt update && apt install -y git &&\
    apt-get autoremove &&\
    apt-get autoclean &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
ENV USER=root
USER root
CMD ["/opt/bin/entry.sh"]