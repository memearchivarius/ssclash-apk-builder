# SSClash APK Builder

Custom `luci-app-ssclash` APK package with pre-baked config and auto kernel download.

## Usage

1. **Edit secrets** in `config.yaml`:
   - Replace `__WARP_PRIVATE_KEY__` with your real key
   - Replace `__BLANC_SUBSCRIPTION_URL__` with your real URL

2. **Deploy via Portainer** (Deploy from Git):
   - Repository: `https://github.com/YOUR_USERNAME/ssclash-apk-builder`
   - Branch: `main`
   - Compose file: `compose.yaml`

3. **Or run locally**:
   ```bash
   mkdir -p output
   docker compose up --build
   ```

4. **Get APK** from `./output/luci-app-ssclash-4.5.1-r1-custom.apk`

## What's inside

- Pre-configured `config.yaml` and `settings`
- `clash-download` script — auto-downloads Mihomo kernel on first boot
- Patched `init.d/clash` — non-blocking when kernel is missing
- Patched `hotplug.d/iface/40-clash` — downloads kernel on WAN up
