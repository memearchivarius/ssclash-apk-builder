FROM alpine:edge

RUN apk add --no-cache apk-tools curl bash tar gzip sed

WORKDIR /build

# Download and extract original APK
RUN curl -fsSL "https://github.com/zerolabnet/ssclash/releases/download/v4.5.1/luci-app-ssclash-4.5.1-r1.apk" -o orig.apk && \
    mkdir -p pkg && \
    apk extract orig.apk -d pkg/

# Copy templates and scripts
COPY config-template.yaml /build/config-template.yaml
COPY settings /build/pkg/opt/clash/settings
COPY patch.sh /build/patch.sh
COPY build.sh /build/build.sh

RUN chmod +x /build/patch.sh /build/build.sh

ENTRYPOINT ["/build/build.sh"]
