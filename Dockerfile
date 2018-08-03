FROM golang:alpine

WORKDIR /

ENV DEP_VERSION=0.5.0
ENV GOLANGCI_LINT_VERSION=1.9.3
ENV XRAY_VERSION=2.0.0
# ENV GLIBC_VERSION=2.26-r0

RUN apk update \
    # Update and updgrage alpine packages
    && apk upgrade \
    # Install required packages
    && apk --no-cache add ca-certificates bash git make \
    # Install required packages to lint go code
    && apk --no-cache add clang gcc libc-dev \
    # Install packages needed for this image to build (cleaned at the end)
    # && apk --no-cache add --virtual build-dependencies git curl jq libgcc unzip gpgme \
    && apk --no-cache add --virtual build-dependencies curl jq unzip gpgme \
    # Install dep
    && curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh \
    # Install golintci-lint
    && curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | bash -s -- -b $GOPATH/bin v${GOLANGCI_LINT_VERSION} \
    # Install AWS
    # && curl -o /usr/local/bin/aws https://raw.githubusercontent.com/mesosphere/aws-cli/master/aws.sh \
    # && chmod a+x /usr/local/bin/aws \
    # Install AWS X-Ray daemon
    # && cd /usr/lib \
    # && xray_url=https://s3.dualstack.us-east-2.amazonaws.com/aws-xray-assets.us-east-2/xray-daemon \
    # && xray_zip=aws-xray-daemon-linux-${XRAY_VERSION}.zip \
    # && curl -O --location --silent --show-error ${xray_url}/${xray_zip} \
    # && curl -O --location --silent --show-error ${xray_url}/${xray_zip}.sig \
    # && curl --location --silent --show-error ${xray_url}/aws-xray.gpg | gpg --import \
    # && gpg --verify ${xray_zip}.sig ${xray_zip} \
    # && unzip -q ${xray_zip} \
    # && chmod +x /usr/lib/xray \
    # && rm -rf ${xray_zip} ${xray_zip}.sig \
    # && ln -s /usr/lib/xray /usr/bin/ \
    # && ln -sf /dev/stdout /var/log/xray-daemon.log \
    # Install go-swagger
    # && latestv=$(curl --location --silent --show-error -s https://api.github.com/repos/go-swagger/go-swagger/releases/latest | jq -r .tag_name) \
    # && curl --location --silent --show-error -o /usr/local/bin/swagger -L'#' https://github.com/go-swagger/go-swagger/releases/download/$latestv/swagger_$(echo `uname`|tr '[:upper:]' '[:lower:]')_amd64 \
    # && chmod +x /usr/local/bin/swagger \
    # Clean build dependancies
    && apk del --purge -r build-dependencies 

EXPOSE 2000/udp

CMD ["bash"]