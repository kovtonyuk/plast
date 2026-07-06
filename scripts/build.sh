#!/bin/bash
# Build script with automatic version bump

set -e

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Parse arguments
BUMP_TYPE="patch"  # default to patch
BUILD_IOS=false
BUILD_ANDROID=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --major)
      BUMP_TYPE="major"
      shift
      ;;
    --minor)
      BUMP_TYPE="minor"
      shift
      ;;
    --patch)
      BUMP_TYPE="patch"
      shift
      ;;
    --ios)
      BUILD_IOS=true
      shift
      ;;
    --android)
      BUILD_ANDROID=true
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# If no platform specified, build both
if [ "$BUILD_IOS" = false ] && [ "$BUILD_ANDROID" = false ]; then
  BUILD_IOS=true
  BUILD_ANDROID=true
fi

# Bump version in pubspec.yaml
bump_version() {
  local type=$1
  local version=$(grep '^version:' pubspec.yaml | awk '{print $2}')
  local build=$(echo $version | cut -d'+' -f2)
  local minor=$(echo $version | cut -d'.' -f2)
  local major=$(echo $version | cut -d'.' -f1 | sed 's/version: //')

  local new_build=$((build + 1))

  case $type in
    major)
      new_minor=0
      new_patch=0
      new_major=$((major + 1))
      ;;
    minor)
      new_minor=$((minor + 1))
      new_patch=0
      new_major=$major
      ;;
    patch)
      new_minor=$minor
      new_patch=0
      new_major=$major
      ;;
  esac

  local new_version="${new_major}.${new_minor}.${new_patch}+${new_build}"
  sed -i '' "s/^version: $version/version: $new_version/" pubspec.yaml
  echo "$new_version"
}

echo "Bumping $BUMP_TYPE version..."
NEW_VERSION=$(bump_version $BUMP_TYPE)
echo "New version: $NEW_VERSION"

# Build platforms
if [ "$BUILD_IOS" = true ]; then
  echo "Building iOS..."
  flutter build ios --simulator --no-codesign
fi

if [ "$BUILD_ANDROID" = true ]; then
  echo "Building Android..."
  flutter build apk --debug
fi

echo "Done! Built version: $NEW_VERSION"
