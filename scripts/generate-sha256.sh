#!/bin/bash
# generate-sha256.sh - Generate SHA256 checksums

set -e

echo "Generating SHA256 checksums..."

# Generate checksum for main EA file
sha256sum EA_MultiPairs_Scalping_Pro.mq5 > EA_MultiPairs_Scalping_Pro.mq5.sha256

echo "✅ SHA256 checksum generated"
cat EA_MultiPairs_Scalping_Pro.mq5.sha256
