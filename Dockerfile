FROM side/go:1.0.1

WORKDIR /

ENV GO_SWAGGER_VERSION=v0.17.2

RUN apk update \
    # Update and updgrage alpine packages
    && apk upgrade \
    # Install packages needed for this image to build (cleaned at the end)
    && apk --no-cache add --virtual build-dependencies curl jq unzip gpgme \
    # Install go-swagger
    && latestv=$(curl --location --silent --show-error -s https://api.github.com/repos/go-swagger/go-swagger/releases/${GO_SWAGGER_VERSION} | jq -r .tag_name) \
    && curl --location --silent --show-error -o /usr/local/bin/swagger -L'#' https://github.com/go-swagger/go-swagger/releases/download/$latestv/swagger_$(echo `uname`|tr '[:upper:]' '[:lower:]')_amd64 \
    && chmod +x /usr/local/bin/swagger \
    # Clean build dependancies
    && apk del --purge -r build-dependencies 

EXPOSE 2000/udp

CMD ["bash"]