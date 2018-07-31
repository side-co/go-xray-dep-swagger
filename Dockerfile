FROM golang:alpine

WORKDIR /
ENV XRAY_VERSION=2.0.0
ENV GOLANGCI_LINT_VERSION=1.9.3

RUN apk --no-cache add ca-certificates git make clang gcc
RUN apk --no-cache add --virtual build-dependencies bash curl jq libgcc unzip gpgme \
    # Install GNU libc
    && GLIBC_VERSION=2.26-r0 \
    && GLIBC_DL_URL="https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}" \
    && curl --location --silent --show-error -O ${GLIBC_DL_URL}/glibc-${GLIBC_VERSION}.apk \
    && curl --location --silent --show-error -O ${GLIBC_DL_URL}/glibc-bin-${GLIBC_VERSION}.apk \
    && curl --location --silent --show-error -O ${GLIBC_DL_URL}/glibc-i18n-${GLIBC_VERSION}.apk \
    && apk add --allow-untrusted glibc-${GLIBC_VERSION}.apk \
       glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk \
    && /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib \
    && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && rm -rf glibc-${GLIBC_VERSION}.apk \
       glibc-bin-${GLIBC_VERSION}.apk glibc-i18n-${GLIBC_VERSION}.apk \
    # Install AWS X-Ray daemon
    && cd /usr/lib \
    && xray_url=https://s3.dualstack.us-east-2.amazonaws.com/aws-xray-assets.us-east-2/xray-daemon \
    && xray_zip=aws-xray-daemon-linux-${XRAY_VERSION}.zip \
    && curl -O --location --silent --show-error ${xray_url}/${xray_zip} \
    && curl -O --location --silent --show-error ${xray_url}/${xray_zip}.sig \
    && curl --location --silent --show-error ${xray_url}/aws-xray.gpg | gpg --import \
    && gpg --verify ${xray_zip}.sig ${xray_zip} \
    && unzip -q ${xray_zip} \
    && chmod +x /usr/lib/xray \
    && rm -rf ${xray_zip} ${xray_zip}.sig \
    && ln -s /usr/lib/xray /usr/bin/ \
    && ln -sf /dev/stdout /var/log/xray-daemon.log \
    # Install go-swagger
    && latestv=$(curl --location --silent --show-error -O -s https://api.github.com/repos/go-swagger/go-swagger/releases/latest | jq -r .tag_name) \
    && curl --location --silent --show-error -o /usr/local/bin/swagger -L'#' https://github.com/go-swagger/go-swagger/releases/download/$latestv/swagger_$(echo `uname`|tr '[:upper:]' '[:lower:]')_amd64 \
    && chmod +x /usr/local/bin/swagger \
    # Install dep
    && curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh \
    # Install golintci-lint
    && curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | bash -s -- -b $GOPATH/bin v${GOLANGCI_LINT_VERSION} \
    # Clean build dependancies
    && apk del --purge -r build-dependencies 

EXPOSE 2000/udp


CMD ["bash"]