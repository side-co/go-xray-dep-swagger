FROM side/go:2.0.0

WORKDIR /

ENV GO_SWAGGER_VERSION=0.17.2

RUN \
    # Add go-swagger apt repository
    echo "deb http://dl.bintray.com/go-swagger/goswagger-debian ubuntu main" | tee -a /etc/apt/sources.list \
    # Update packages
    && apt-get update \
    # Upgrade packages
    && apt-get upgrade -y \
    # Install go-swagger
    && apt-get install -y --no-install-recommends --allow-unauthenticated \
    swagger=${GO_SWAGGER_VERSION} \
    # Clean up APT when done.
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 2000/udp

CMD ["bash"]