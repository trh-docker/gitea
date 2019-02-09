FROM quay.io/spivegin/golangnodesj AS dev-build
WORKDIR /opt/src/src/code.gitea.io/
ADD Makefile /opt/Makefile
RUN apt-get update && apt-get install -y zip libpam0g-dev 
# git clone https://github.com/go-gitea/gitea.git &&\
ARG GITEA_VERSION
ARG TAGS="sqlite sqlite_unlock_notify"
ENV TAGS "bindata $TAGS"

#Checkout version if set
RUN git clone https://github.com/go-gitea/gitea.git &&\
    cd gitea && cp /opt/Makefile . &&\
    make clean generate build
  
FROM debian:stretch-slim
RUN mkdir -p /opt/bin/ 
COPY --from=dev-build /opt/src/src/code.gitea.io/gitea/gitea /opt/bin/gitea
# COPY --from=dev-build /opt/gogs /opt/
WORKDIR /opt/gitea
ADD entry.sh /opt/bin/
RUN chmod +x /opt/bin/entry.sh && chmod +x /opt/bin/gitea &&\
    ln -s /opt/bin/gitea /bin/gitea &&\
    apt update && apt install -y git &&\
    apt-get autoremove &&\
    apt-get autoclean &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
ENV USER root
ENV GITEA_CUSTOM /opt/gitea
USER root
CMD ["/opt/bin/entry.sh"]