#!/bin/bash
# ===========================================================================
# File: load-images.sh
# Description: Load offline Docker images from the images/ directory
# Usage:      ./load-images.sh
# ===========================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGES_DIR="${SCRIPT_DIR}/images"
MANIFEST="${SCRIPT_DIR}/images.txt"

if [ ! -d "${IMAGES_DIR}" ]; then
    echo "[ERROR] images directory not found: ${IMAGES_DIR}"
    exit 1
fi

echo "======================================"
echo "  APIPark Offline Image Importer"
echo "======================================"

# Load all .tar files
count=0
for tar_file in "${IMAGES_DIR}"/*.tar; do
    if [ ! -f "$tar_file" ]; then
        echo "[WARN] No .tar files found in ${IMAGES_DIR}"
        exit 1
    fi
    echo "[INFO] Loading: $(basename "$tar_file")"
    docker load -i "$tar_file"
    count=$((count + 1))
done

echo ""
echo "[OK] Loaded ${count} image(s)."

# Show loaded images
echo ""
echo "Loaded Docker images:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | head -1
if [ -f "${MANIFEST}" ]; then
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        repo=$(echo "$line" | awk -F: '{print $1}')
        tag=$(echo "$line" | awk -F: '{print $2}')
        docker images --format "{{.Repository}}\t{{.Tag}}\t{{.Size}}" \
            | grep -E "^${repo}\s+${tag}\s" || true
    done < "${MANIFEST}"
fi

echo ""
echo "======================================"
echo "  Done! You can now run:"
echo "  docker compose -f docker-compose.yml up -d"
echo "======================================"
