#!/bin/bash
#
# Author  : Sylvain Deguire (VA2OPS)
# Date    : January 2025
# Purpose : Install custom EmComm-Tools articles to the wiki

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

CONTENT_DIR="content/articles"

echo "[INFO] Installing custom articles..."

# Create directories if needed
mkdir -p "${CONTENT_DIR}/software"
mkdir -p "${CONTENT_DIR}/digital-modes"
mkdir -p "${CONTENT_DIR}/radios"
mkdir -p "${CONTENT_DIR}/emcomm"
mkdir -p "${CONTENT_DIR}/reference"

# Software articles
for f in js8call.html pat-winlink.html yaac.html fldigi-guide.html direwolf.html; do
    if [[ -f "$f" ]]; then
        cp -v "$f" "${CONTENT_DIR}/software/"
    fi
done

# Digital mode articles
for f in vara.html varac.html ardop.html; do
    if [[ -f "$f" ]]; then
        cp -v "$f" "${CONTENT_DIR}/digital-modes/"
    fi
done

# Radio/equipment articles
for f in digirig-setup.html; do
    if [[ -f "$f" ]]; then
        cp -v "$f" "${CONTENT_DIR}/radios/"
    fi
done

# EmComm articles
for f in ics-forms-guide.html; do
    if [[ -f "$f" ]]; then
        cp -v "$f" "${CONTENT_DIR}/emcomm/"
    fi
done

# Reference articles
for f in digital-frequencies.html; do
    if [[ -f "$f" ]]; then
        cp -v "$f" "${CONTENT_DIR}/reference/"
    fi
done

echo "[INFO] Custom articles installed!"
echo "[INFO] Run ./scripts/generate-index.sh to update the index."
echo "[INFO] Then run ./build.sh to rebuild the ZIM file."
