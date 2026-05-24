#!/bin/sh
set -e

# Substitute secrets from environment variables
cp /build/config-template.yaml /build/pkg/opt/clash/config.yaml
sed -i "s|__WARP_PRIVATE_KEY__|${WARP_PRIVATE_KEY}|g" /build/pkg/opt/clash/config.yaml
sed -i "s|__BLANC_SUBSCRIPTION_URL__|${BLANC_SUBSCRIPTION_URL}|g" /build/pkg/opt/clash/config.yaml

echo "[*] Config patched with secrets"

# Apply patches
/build/patch.sh

# Build APK
echo "[*] Building custom APK..."
apk mkpkg /build/pkg/ -o /output/luci-app-ssclash-4.5.1-r1-custom.apk

echo "[*] Done!"
ls -lh /output/luci-app-ssclash-4.5.1-r1-custom.apk
