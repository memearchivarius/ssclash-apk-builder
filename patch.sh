#!/bin/sh
set -e

# Add clash-download script
cat > /build/pkg/opt/clash/bin/clash-download << 'DOWNLOAD'
#!/bin/sh
CLASH_BIN="/opt/clash/bin/clash"
[ -f "$CLASH_BIN" ] && exit 0
[ -f "/tmp/mihomo-download.lock" ] && exit 0
touch /tmp/mihomo-download.lock
logger -t clash-download "Waiting for internet..."
for i in $(seq 1 30); do
    wget -qO- http://detectportal.firefox.com/success.txt >/dev/null 2>&1 && break
    sleep 2
done
wget -qO /tmp/mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/v1.19.24/mihomo-linux-arm64-v1.19.24.gz" 2>/dev/null || \
    curl -fsSL "https://github.com/MetaCubeX/mihomo/releases/download/v1.19.24/mihomo-linux-arm64-v1.19.24.gz" -o /tmp/mihomo.gz
gunzip -c /tmp/mihomo.gz > "$CLASH_BIN"
chmod +x "$CLASH_BIN"
rm -f /tmp/mihomo.gz /tmp/mihomo-download.lock
logger -t clash-download "Kernel installed, starting clash"
/etc/init.d/clash start
DOWNLOAD
chmod +x /build/pkg/opt/clash/bin/clash-download

# Patch init.d/clash
sed -i '/^start_service() {$/,/^# Check the required files$/{/^# Check the required files$/i\
\
\t# If kernel missing, download in background and exit cleanly\
\tif [ ! -f "$CLASH_BIN" ]; then\
\t\tmsg "Kernel missing, starting background download"\
\t\t( /opt/clash/bin/clash-download ) \&\
\t\treturn 0\
\tfi
}' /build/pkg/etc/init.d/clash

sed -i 's/^boot() {$/boot() {\
\tif [ ! -f "$CLASH_BIN" ]; then\
\t\t( sleep 5; \/opt\/clash\/bin\/clash-download ) \&\
\t\treturn 0\
\tfi/' /build/pkg/etc/init.d/clash

# Patch hotplug
sed -i 's/^\[ "$ACTION" = "ifup" \] || exit 0/[ "$ACTION" = "ifup" ] || exit 0\
\
if [ ! -f "\/opt\/clash\/bin\/clash" ] \&\& [ -x "\/opt\/clash\/bin\/clash-download" ]; then\
\tlogger -t clash-hotplug "Kernel missing, triggering download"\
\t( sleep 5; \/opt\/clash\/bin\/clash-download ) \&\
\texit 0\
fi/' /build/pkg/etc/hotplug.d/iface/40-clash

echo "[*] Patches applied"
