#!/bin/bash
set -e

# Substitute secrets from environment variables
cp /build/config-template.yaml /build/pkg/opt/clash/config.yaml
sed -i "s|__WARP_PRIVATE_KEY__|${WARP_PRIVATE_KEY}|g" /build/pkg/opt/clash/config.yaml
sed -i "s|__BLANC_SUBSCRIPTION_URL__|${BLANC_SUBSCRIPTION_URL}|g" /build/pkg/opt/clash/config.yaml

echo "[*] Config patched with secrets"

# Apply patches
/build/patch.sh

# Extract metadata and scripts from original APK using adumpk
echo "[*] Extracting original metadata and scripts..."
python3 /build/adumpk.py /build/orig.apk --json /tmp/orig.json

# Parse metadata and write scripts
python3 -c "
import json, base64, sys

with open('/tmp/orig.json') as f:
    data = json.load(f)

pkginfo = data.get('pkginfo', {})

# Build metadata map for apk mkpkg --info
fields = {
    'name': pkginfo.get('name', 'luci-app-ssclash'),
    'version': pkginfo.get('version', '4.5.1-r1'),
    'description': pkginfo.get('description', 'LuCI interface for SSClash'),
    'arch': pkginfo.get('arch', 'noarch'),
    'license': pkginfo.get('license', 'MIT'),
    'origin': pkginfo.get('origin', 'ssclash'),
    'url': pkginfo.get('url', 'https://github.com/zerolabnet/ssclash'),
    'maintainer': pkginfo.get('maintainer', 'Custom Build'),
}

# provides
provides = pkginfo.get('provides', [])
if provides:
    fields['provides'] = ' '.join(provides)

# depends
depends = pkginfo.get('depends', [])
if depends:
    fields['depends'] = ' '.join(depends)

# Write metadata lines
with open('/tmp/pkginfo.txt', 'w') as f:
    for k, v in fields.items():
        if v:
            f.write(f'{k}={v}\n')

# Script name mapping: adumpk -> apk mkpkg --script type
script_map = {
    'postinst':   'post-install',
    'preinst':    'pre-install',
    'postdeinst': 'post-deinstall',
    'predeinst':  'pre-deinstall',
    'postupgrade':'post-upgrade',
    'preupgrade': 'pre-upgrade',
}

scripts = data.get('scripts', {})
for name, b64 in scripts.items():
    if not b64 or name == 'trigger':
        continue
    stype = script_map.get(name, name)
    path = f'/tmp/script-{stype}'
    try:
        content = base64.b64decode(b64)
        with open(path, 'wb') as sf:
            sf.write(content)
        print(f'SCRIPT:{stype}:{path}')
    except Exception as e:
        print(f'ERROR:{name}:{e}', file=sys.stderr)
" > /tmp/scripts.txt

# Build apk mkpkg argument array to avoid word-splitting issues
MKPKG_ARGS=()

while IFS='=' read -r key value; do
    [ -z "$key" ] && continue
    MKPKG_ARGS+=(--info "${key}:${value}")
done < /tmp/pkginfo.txt

while IFS=':' read -r kind stype path; do
    [ "$kind" = "SCRIPT" ] || continue
    [ -f "$path" ] || continue
    MKPKG_ARGS+=(--script "${stype}:${path}")
done < /tmp/scripts.txt

MKPKG_ARGS+=(--files /build/pkg)
MKPKG_ARGS+=(--output /output/luci-app-ssclash-4.5.1-r1-custom.apk)

echo "[*] Building custom APK..."
apk mkpkg "${MKPKG_ARGS[@]}"

echo "[*] Done!"
ls -lh /output/luci-app-ssclash-4.5.1-r1-custom.apk
