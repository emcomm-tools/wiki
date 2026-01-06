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
    
    if ! command -v zimwriterfs &> /dev/null; then
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

# Build the ZIM file
build_zim() {
    log_info "Building ZIM file: ${OUTPUT_FILE}"
    
    # Ensure favicon exists
    if [[ ! -f "${WIKI_FAVICON}" ]]; then
        log_warn "Favicon not found, creating placeholder..."
        mkdir -p "$(dirname "${WIKI_FAVICON}")"
        # Create a simple 48x48 red/white ham radio icon placeholder
        convert -size 48x48 xc:white -fill red \
            -draw "circle 24,24 24,4" \
            -fill white -draw "circle 24,24 24,12" \
            -fill red -draw "circle 24,24 24,20" \
            "${WIKI_FAVICON}" 2>/dev/null || \
        # Fallback: create a simple PNG if ImageMagick not available
        echo -e '\x89PNG\r\n\x1a\n' > "${WIKI_FAVICON}"
    fi
    
    zimwriterfs \
        --welcome="${WIKI_MAIN_PAGE}" \
        --favicon="${WIKI_FAVICON}" \
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
