#!/bin/bash
# version-bump.sh - Bump version in all files

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <new_version>"
    exit 1
fi

NEW_VERSION=$1

echo "Bumping version to $NEW_VERSION..."

# Update VERSION.txt
echo "$NEW_VERSION" > VERSION.txt

# Update EA file #property version
sed -i "s/#property version.*/#property version   \"$NEW_VERSION\"/" EA_MultiPairs_Scalping_Pro.mq5

# Update CURRENT_VERSION constant
sed -i "s/#define CURRENT_VERSION.*/#define CURRENT_VERSION \"$NEW_VERSION\"/" EA_MultiPairs_Scalping_Pro.mq5

echo "✅ Version bumped to $NEW_VERSION"
