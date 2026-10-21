#!/usr/bin/env bash
#Builds build/package: Lambda code + pg8000 + the RDS CA bundle.
set -euo pipefail
cd "$(dirname "$0")/.."
rm -rf build && mkdir -p build/package
pip install --quiet --target build/package -r lambda/requirements.txt
cp lambda/*.py build/package/
curl -fsSL https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem -o build/package/rds-ca.pem
echo "Built build/package"
