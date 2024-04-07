FROM hashicorp/packer:1.10

# Update and install dependencies
RUN apk --no-cache update && \
    apk --no-cache upgrade && \
    apk add --no-cache make && \
    # Add any specific packages you need to install here, e.g., apk add --no-cache git
    rm -rf /var/cache/apk/*

WORKDIR /app