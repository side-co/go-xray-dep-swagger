FROM golang:alpine

WORKDIR /

ENV DEP_VERSION=0.5.0
ENV GOLANGCI_LINT_VERSION=1.9.3
ENV XRAY_VERSION=2.0.0
# ENV GLIBC_VERSION=2.26-r0

RUN apk update \
    # Update and updgrage alpine packages
    && apk upgrade \
    # Install required packages (libc6-compat => x-ray)
    && apk --no-cache add ca-certificates bash git make libc6-compat \
    # Install required packages to lint go code
    && apk --no-cache add clang gcc libc-dev \
    # Install packages needed for this image to build (cleaned at the end)
    && apk --no-cache add --virtual build-dependencies curl jq unzip gpgme \
    # Install dep
    && curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh \
    # Install golintci-lint
    && curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | bash -s -- -b $GOPATH/bin v${GOLANGCI_LINT_VERSION} \
    && rm -rf /tmp/* \
    # Install AWS
    # && curl -o /usr/local/bin/aws https://raw.githubusercontent.com/mesosphere/aws-cli/master/aws.sh \
    # && chmod a+x /usr/local/bin/aws \
    # Install AWS X-Ray daemon
    && curl https://s3.dualstack.us-east-1.amazonaws.com/aws-xray-assets.us-east-1/xray-daemon/aws-xray-daemon-linux-2.x.zip -o install.zip \ 
    && unzip install.zip -d xray_install \ 
    && mkdir -p xray_install \ 
    && mv xray_install/xray /usr/bin/xray \ 
    && rm -rf install.zip xray_install \ 
    && apk del --purge -r build-dependencies 
    # Install go-swagger
    # && latestv=$(curl --location --silent --show-error -s https://api.github.com/repos/go-swagger/go-swagger/releases/latest | jq -r .tag_name) \
    # && curl --location --silent --show-error -o /usr/local/bin/swagger -L'#' https://github.com/go-swagger/go-swagger/releases/download/$latestv/swagger_$(echo `uname`|tr '[:upper:]' '[:lower:]')_amd64 \
    # && chmod +x /usr/local/bin/swagger \
    # Clean build dependancies


EXPOSE 2000/udp

CMD ["bash"]