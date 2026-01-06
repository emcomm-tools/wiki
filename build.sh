#!/bin/bash
#
# Author  : Sylvain Deguire (VA2OPS)
# Date    : January 2025
# Purpose : Build the EmComm-Tools Ham Radio Wiki ZIM file

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# Load configuration
source ./config.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing=0
    
# Remove existing ZIM file
[[ -f "${OUTPUT_DIR}/${OUTPUT_FILE}" ]] && rm -f "${OUTPUT_DIR}/${OUTPUT_FILE}"
    if ! command -v zimwriterfs &> /dev/null; then
# Remove existing ZIM file
[[ -f "${OUTPUT_DIR}/${OUTPUT_FILE}" ]] && rm -f "${OUTPUT_DIR}/${OUTPUT_FILE}"
        log_error "zimwriterfs not found. Install with: apt install zim-tools"
        missing=1
    fi
    
    if ! command -v curl &> /dev/null; then
        log_error "curl not found. Install with: apt install curl"
        missing=1
    fi
    
    if ! command -v python3 &> /dev/null; then
        log_error "python3 not found. Install with: apt install python3"
        missing=1
    fi
    
    if ! command -v convert &> /dev/null; then
        log_warn "ImageMagick not found. Will create basic favicon."
    fi
    
    if [[ $missing -eq 1 ]]; then
        exit 1
    fi
    
    log_info "All dependencies satisfied."
}

# Create output directory
prepare_output() {
    log_info "Preparing output directory..."
    mkdir -p "${OUTPUT_DIR}"
}

# Generate the index page
generate_index() {
    log_info "Generating index page..."
    ./scripts/generate-index.sh
}

# Fetch Wikipedia articles if requested
fetch_wikipedia() {
    if [[ "$1" == "--fetch-wikipedia" ]]; then
        log_info "Fetching Wikipedia articles..."
        ./scripts/fetch-wikipedia.sh
    fi
}

# Validate content before building
validate_content() {
    log_info "Validating content..."
    
    if [[ ! -f "${CONTENT_DIR}/index.html" ]]; then
        log_error "Missing index.html in ${CONTENT_DIR}"
        exit 1
    fi
    
    # Count articles
    local article_count=$(find "${CONTENT_DIR}" -name "*.html" | wc -l)
    log_info "Found ${article_count} HTML articles."
    
    if [[ $article_count -lt 1 ]]; then
        log_error "No articles found. Run with --fetch-wikipedia or add content manually."
        exit 1
    fi
}

# Create illustration/favicon PNG
create_illustration() {
    local illust_path="${CONTENT_DIR}/illustration.png"
    
    if [[ -f "${illust_path}" ]]; then
        log_info "Illustration already exists."
        return 0
    fi
    
    log_info "Creating illustration (48x48 PNG)..."
    
    if command -v convert &> /dev/null; then
        # Create a simple ham radio themed icon with ImageMagick
        convert -size 48x48 xc:'#2c5282' \
            -fill white -draw "circle 24,24 24,8" \
            -fill '#2c5282' -draw "circle 24,24 24,14" \
            -fill white -draw "circle 24,24 24,20" \
            -fill '#ed8936' -draw "rectangle 20,22 28,40" \
            "${illust_path}" 2>/dev/null || {
                # Fallback: simple colored square
                convert -size 48x48 xc:'#2c5282' "${illust_path}"
            }
    else
        # Create minimal valid PNG without ImageMagick
        # This is a 48x48 blue PNG
        python3 << 'PYEOF'
import zlib
import struct

def create_png(filename, width=48, height=48, color=(44, 82, 130)):
    def png_chunk(chunk_type, data):
        chunk_len = struct.pack('>I', len(data))
        chunk_crc = struct.pack('>I', zlib.crc32(chunk_type + data) & 0xffffffff)
        return chunk_len + chunk_type + data + chunk_crc

    # PNG signature
    signature = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    ihdr = png_chunk(b'IHDR', ihdr_data)
    
    # IDAT chunk (image data)
    raw_data = b''
    for y in range(height):
        raw_data += b'\x00'  # filter byte
        for x in range(width):
            raw_data += bytes(color)
    
    compressed = zlib.compress(raw_data)
    idat = png_chunk(b'IDAT', compressed)
    
    # IEND chunk
    iend = png_chunk(b'IEND', b'')
    
    with open(filename, 'wb') as f:
        f.write(signature + ihdr + idat + iend)

create_png("content/articles/illustration.png")
print("Created illustration.png")
PYEOF
    fi
    
    if [[ -f "${illust_path}" ]]; then
        log_info "Illustration created: ${illust_path}"
    else
        log_error "Failed to create illustration"
        exit 1
    fi
}

# Build the ZIM file
build_zim() {
    log_info "Building ZIM file: ${OUTPUT_FILE}"
    
    # Ensure illustration exists
    create_illustration
    
# Remove existing ZIM file
[[ -f "${OUTPUT_DIR}/${OUTPUT_FILE}" ]] && rm -f "${OUTPUT_DIR}/${OUTPUT_FILE}"
    zimwriterfs \
        --welcome=index.html \
        --illustration=illustration.png \
        --language="${WIKI_LANGUAGE}" \
        --title="${WIKI_TITLE}" \
        --description="${WIKI_DESCRIPTION}" \
        --creator="${WIKI_CREATOR}" \
        --publisher="${WIKI_PUBLISHER}" \
        --name="${WIKI_NAME}" \
        "${CONTENT_DIR}" \
        "${OUTPUT_DIR}/${OUTPUT_FILE}"
    
    if [[ -f "${OUTPUT_DIR}/${OUTPUT_FILE}" ]]; then
        local size=$(du -h "${OUTPUT_DIR}/${OUTPUT_FILE}" | cut -f1)
        log_info "Successfully built: ${OUTPUT_DIR}/${OUTPUT_FILE} (${size})"
    else
        log_error "Failed to create ZIM file"
        exit 1
    fi
}

# Show usage
usage() {
    cat << EOF
EmComm-Tools Ham Radio Wiki Builder

Usage: $0 [OPTIONS]

Options:
    --fetch-wikipedia    Fetch articles from Wikipedia before building
    --validate-only      Only validate content, don't build
    --help               Show this help message

Examples:
    $0                       # Build with existing content
    $0 --fetch-wikipedia     # Fetch Wikipedia articles then build
    $0 --validate-only       # Check content without building
EOF
}

# Main execution
main() {
    echo "========================================"
    echo "EmComm-Tools Ham Radio Wiki Builder"
    echo "Build date: ${BUILD_DATE}"
    echo "========================================"
    echo ""
    
    case "$1" in
        --help)
            usage
            exit 0
            ;;
        --validate-only)
            check_dependencies
            validate_content
            log_info "Validation complete."
            exit 0
            ;;
        --fetch-wikipedia)
            check_dependencies
            prepare_output
            fetch_wikipedia "$1"
            generate_index
            validate_content
            build_zim
            ;;
        "")
            check_dependencies
            prepare_output
            generate_index
            validate_content
            build_zim
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
    
    echo ""
    log_info "Build complete!"
    echo ""
    echo "To install, copy to your wikipedia directory:"
    echo "  cp ${OUTPUT_DIR}/${OUTPUT_FILE} ~/wikipedia/"
    echo ""
}

main "$@"
