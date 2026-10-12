#!/usr/bin/env bash
# Usage: ./generate-traffic.sh https://api.<your-cis-domain> [rounds]
# Run from your laptop (outside Cloudflare). Default 700 rounds ≈ 700 hits per collection endpoint.
set -u
HOST="${1:?Usage: $0 https://api.<your-cis-domain> [rounds]}"
ROUNDS="${2:-700}"
PATHS=(/api/v1/status.json /api/v1/users.json /api/v1/products.json)
USER_IDS=(1 2 3)
PRODUCT_IDS=(101 102 103)
for i in $(seq 1 "$ROUNDS"); do
  TOKEN="test-session-$((RANDOM % 20))"
  ALL=("${PATHS[@]}" "/api/v1/users/${USER_IDS[$((RANDOM % 3))]}.json" "/api/v1/products/${PRODUCT_IDS[$((RANDOM % 3))]}.json")
  for p in "${ALL[@]}"; do
    curl -s -o /dev/null -w "%{http_code} %header{cf-cache-status} $p\n" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Accept: application/json" \
      -A "cis-discovery-test/1.0" \
      "$HOST$p"
  done
  echo "--- round $i/$ROUNDS"
  sleep 1
done
