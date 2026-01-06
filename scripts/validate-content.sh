#!/bin/bash
#
# Author  : Sylvain Deguire (VA2OPS)
# Date    : January 2025
# Purpose : Validate wiki content for broken links and issues

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.."

source ./config.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

errors=0
warnings=0

log_info "Validating content in ${CONTENT_DIR}..."

# Check for index.html
if [[ ! -f "${CONTENT_DIR}/index.html" ]]; then
    log_error "Missing index.html"
    ((errors++))
fi

# Check for CSS
if [[ ! -f "${CONTENT_DIR}/css/style.css" ]]; then
    log_error "Missing css/style.css"
    ((errors++))
fi

# Find all HTML files
html_files=$(find "${CONTENT_DIR}" -name "*.html" -type f)
total_files=$(echo "$html_files" | wc -l)

log_info "Found ${total_files} HTML files"

# Check each HTML file for broken internal links
for file in $html_files; do
    dir=$(dirname "$file")
    
    # Extract href links
    links=$(grep -oP 'href="\K[^"]+' "$file" 2>/dev/null | grep -v "^http" | grep -v "^#" || true)
    
    for link in $links; do
        # Resolve relative path
        if [[ "$link" == ../* ]]; then
            target=$(cd "$dir" && realpath -m "$link" 2>/dev/null || echo "")
        else
            target="${dir}/${link}"
        fi
        
        # Check if target exists
        if [[ -n "$target" && ! -f "$target" && ! -d "$target" ]]; then
            # Check without the directory
            basename_link=$(basename "$link")
            if [[ ! -f "${CONTENT_DIR}/${basename_link}" ]]; then
                log_warn "Broken link in $(basename "$file"): $link"
                ((warnings++))
            fi
        fi
    done
done

# Check for empty categories
for cat in ${CATEGORIES}; do
    cat_dir="${CONTENT_DIR}/${cat}"
    if [[ -d "$cat_dir" ]]; then
        count=$(find "$cat_dir" -name "*.html" -type f | wc -l)
        if [[ $count -eq 0 ]]; then
            log_warn "Empty category: ${cat}"
            ((warnings++))
        else
            log_info "Category ${cat}: ${count} articles"
        fi
    fi
done

# Summary
echo ""
echo "========================================"
echo "Validation Summary"
echo "========================================"
echo "Total files: ${total_files}"
echo -e "Errors: ${RED}${errors}${NC}"
echo -e "Warnings: ${YELLOW}${warnings}${NC}"
echo "========================================"

if [[ $errors -gt 0 ]]; then
    exit 1
fi

exit 0
