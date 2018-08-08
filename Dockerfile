FROM golang:alpine

WORKDIR /

ENV DEP_VERSION=0.5.0
ENV GOLANGCI_LINT_VERSION=1.9.3

RUN apk update \
    # Update and updgrage alpine packages
    && apk upgrade \
    # Install required packages 
    && apk --no-cache add ca-certificates bash git make \
    # Install required packages to lint go code
    && apk --no-cache add clang gcc libc-dev \
    # Install packages needed for this image to build (cleaned at the end)
    && apk --no-cache add --virtual build-dependencies curl jq unzip gpgme \
    # Install dep
    && curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh \
    # Install golintci-lint
    && curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | bash -s -- -b $GOPATH/bin v${GOLANGCI_LINT_VERSION} \
    && rm -rf /tmp/* \
    # Install go-swagger
    && latestv=$(curl --location --silent --show-error -s https://api.github.com/repos/go-swagger/go-swagger/releases/latest | jq -r .tag_name) \
    && curl --location --silent --show-error -o /usr/local/bin/swagger -L'#' https://github.com/go-swagger/go-swagger/releases/download/$latestv/swagger_$(echo `uname`|tr '[:upper:]' '[:lower:]')_amd64 \
    && chmod +x /usr/local/bin/swagger \
    # Clean build dependancies
    && apk del --purge -r build-dependencies 

EXPOSE 2000/udp

CMD ["bash"]