FROM ubuntu:18.04
ARG SRV1C_VERSION POSTGRES_VERSION
ENV SRV1C_VERSION=$SRV1C_VERSION POSTGRES_VERSION=$POSTGRES_VERSION DISTR_DIR=/tmp/distr/ SRV1CV8_DEBUG=1
ADD ./distr $DISTR_DIR
ADD *.sh /usr/src/deploy1c/
WORKDIR /usr/src/deploy1c/
RUN chmod +x /usr/src/deploy1c/deployer.sh && /usr/src/deploy1c/deployer.sh
VOLUME data/logs1c/ /data/config1c/
EXPOSE 1540 1541 1550 1560-1591 5432
ENTRYPOINT ["/usr/src/deploy1c/entrypoint.sh"]