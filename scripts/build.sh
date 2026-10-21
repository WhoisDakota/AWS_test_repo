#!/usr/bin/env bash
# Builds build/package: Lambda code + pg8000 + the RDS CA bundle.
set -euo pipefail
cd "$(dirname "$0")/.."

PY=""
for candidate in python py python3; do
  if command -v "$candidate" >/dev/null 2>&1 && "$candidate" --version >/dev/null 2>&1; then
    PY="$candidate"; break
  fi
done
[ -n "$PY" ] || { echo "Python not found. Install it from python.org and tick 'Add to PATH'."; exit 1; }

rm -rf build && mkdir -p build/package
"$PY" -m pip install --quiet --target build/package -r lambda/requirements.txt
cp lambda/*.py build/package/
curl -fsSL https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem -o build/package/rds-ca.pem
echo "Built build/package"