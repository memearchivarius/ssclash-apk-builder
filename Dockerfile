FROM alpine:edge

RUN apk add --no-cache python3 curl bash tar gzip sed

WORKDIR /build

# Download original APK and adumpk
RUN curl -fsSL "https://github.com/zerolabnet/ssclash/releases/download/v4.5.1/luci-app-ssclash-4.5.1-r1.apk" -o orig.apk && \
    curl -fsSL "https://raw.githubusercontent.com/7Ji/adumpk/master/adumpk.py" -o adumpk.py

# Extract APK v3 to tar, then unpack
RUN python3 adumpk.py orig.apk --tar pkg.tar && \
    mkdir -p pkg && \
    tar -xf pkg.tar -C pkg/

# Copy templates and scripts
COPY config-template.yaml /build/config-template.yaml
COPY settings /build/pkg/opt/clash/settings
COPY patch.sh /build/patch.sh
COPY build.sh /build/build.sh

RUN chmod +x /build/patch.sh /build/build.sh

ENTRYPOINT ["/build/build.sh"]
