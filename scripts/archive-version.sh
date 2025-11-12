#!/bin/bash
# archive-version.sh - Archive current version

set -e

if [ ! -f "VERSION.txt" ]; then
    echo "❌ VERSION.txt not found"
    exit 1
fi

VERSION=$(cat VERSION.txt | tr -d '[:space:]')
ARCHIVE_DIR="archive/v$VERSION"

echo "Archiving version $VERSION..."

# Create archive directory
mkdir -p "$ARCHIVE_DIR"

# Copy main files
cp EA_MultiPairs_Scalping_Pro.mq5 "$ARCHIVE_DIR/"
cp -r includes "$ARCHIVE_DIR/"
cp -r configs "$ARCHIVE_DIR/" 2>/dev/null || true

# Create archive
cd archive
zip -r "EA_Scalping_Pro_v$VERSION.zip" "v$VERSION"
cd ..

echo "✅ Version $VERSION archived to $ARCHIVE_DIR"
