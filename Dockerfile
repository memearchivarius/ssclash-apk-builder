FROM alpine:edge

RUN apk add --no-cache apk-tools curl bash tar gzip sed

WORKDIR /build

# Download original APK
RUN curl -fsSL "https://github.com/zerolabnet/ssclash/releases/download/v4.5.1/luci-app-ssclash-4.5.1-r1.apk" -o orig.apk

# Extract APK v3
RUN mkdir -p pkg && apk extract orig.apk -d pkg/

# Copy custom configs
COPY config.yaml /build/pkg/opt/clash/config.yaml
COPY settings /build/pkg/opt/clash/settings
COPY patch.sh /build/patch.sh

# Apply patches and build
RUN chmod +x /build/patch.sh && /build/patch.sh

CMD ["cp", "/build/luci-app-ssclash-4.5.1-r1-custom.apk", "/output/"]
