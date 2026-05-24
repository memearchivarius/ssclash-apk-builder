# SSClash APK Builder

Custom `luci-app-ssclash` APK package with pre-baked config and auto kernel download.

## Environment Variables (set in Portainer)

| Variable | Description |
|----------|-------------|
| `WARP_PRIVATE_KEY` | Your WARP private key |
| `BLANC_SUBSCRIPTION_URL` | Your Blanc subscription URL |

## Deploy via Portainer (Deploy from Git)

1. In Portainer → Stacks → Deploy from Git:
   - Repository URL: `https://github.com/YOUR_USERNAME/ssclash-apk-builder`
   - Branch: `main`
   - Compose file: `compose.yaml`

2. **Set Environment Variables** in Portainer before deploying:
   - `WARP_PRIVATE_KEY` = your real key
   - `BLANC_SUBSCRIPTION_URL` = your real URL

3. Deploy stack. Container will build and exit after creating APK.

4. Get APK from container volume `/output` or host `./output`.

## Run locally

```bash
export WARP_PRIVATE_KEY="your-key"
export BLANC_SUBSCRIPTION_URL="your-url"
mkdir -p output
docker compose up --build
ls output/
```
