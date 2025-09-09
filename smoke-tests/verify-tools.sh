# site-ops-runner/smoke-tests/verify-tools.sh
set -euo pipefail

# Basic tool presence
for bin in bash curl jq yq openssl docker; do
  command -v "$bin" >/dev/null || { echo "missing $bin"; exit 1; }
done

# sanity checks
openssl rand -base64 12 >/dev/null
jq --version
yq --version
docker --version
docker compose version || docker-compose version || true

echo "OK: runner has required tools."
