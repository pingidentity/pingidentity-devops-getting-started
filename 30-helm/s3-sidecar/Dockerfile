## Dockerfile for AWS CLI
## For demonstration purposes only
## Not intended for production use
FROM pingidentity/pingtoolkit:latest

USER root

# Install AWS CLI
RUN apk add --no-cache \
    aws-cli \
    bash \
    curl \
    less \
    groff \
    shadow \
    sudo \
    unzip

USER 9031:0
