FROM gcr.io/google_containers/ubuntu-slim:0.14

ENV DEBIAN_FRONTEND='noninteractive'
ENV PTS_URL='http://www.phoronix-test-suite.com/download.php?file='
ENV PTS_VERSION='7.4.0'
ENV PTS_SHA256SUM='de9aec3ef4f980581756fd0bf7b30dd1ccb20e7aae637078a587' 
ENV TINI_VERSION v0.16.1

RUN apt-get update -qq && \
    apt-get install -qqy --no-install-recommends util-linux ca-certificates curl \
    build-essential unzip mesa-utils php7.0-cli php7.0-gd axel \
    php7.0-json php7.0-xml procps \
    $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') && \
    file="phoronix-test-suite_${PTS_VERSION}.tgz" && \
    echo "downloading $file ..." && \
    axel --output=pts.tgz ${PTS_URL}phoronix-test-suite-${PTS_VERSION}  && \
    sha256sum pts.tgz | grep -q "$PTS_SHA256SUM" || \
    { echo "expected $PTS_SHA256SUM, got $(sha256sum pts.tgz)"; exit 13; } && \
    tar xf pts.tgz && \
    (cd phoronix-test-suite && ./install-sh) && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* phoronix-test-suite pts.tgz

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]
CMD ["/bin/bash"]
