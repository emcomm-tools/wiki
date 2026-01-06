#!/bin/bash
#
# Author  : Sylvain Deguire (VA2OPS)
# Date    : January 2025
# Purpose : Generate the main index page for the Ham Radio Wiki

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.."

source ./config.sh

log_info() {
    echo "[INFO] $1"
}

# Category display names and icons
declare -A CATEGORY_NAMES
CATEGORY_NAMES=(
    ["bandplans"]="📻 Band Plans & Frequencies"
    ["digital-modes"]="💻 Digital Modes"
    ["software"]="🖥️ Software & Applications"
    ["radios"]="📡 Radios & Equipment"
    ["antennas"]="📶 Antennas"
    ["electronics"]="⚡ Electronics & Theory"
    ["emcomm"]="🚨 Emergency Communications"
    ["propagation"]="🌍 Propagation"
    ["reference"]="📚 Quick Reference"
)

declare -A CATEGORY_DESC
CATEGORY_DESC=(
    ["bandplans"]="Amateur band allocations, frequency charts, and mode segments for all ITU regions."
    ["digital-modes"]="FT8, JS8Call, VARA, PSK31, RTTY, and other digital communication modes."
    ["software"]="Guides for amateur radio software included in EmComm-Tools."
    ["radios"]="Transceiver settings, CAT control, and equipment guides."
    ["antennas"]="Antenna theory, construction guides, and wire length calculators."
    ["electronics"]="Electronic fundamentals, filters, impedance matching, and troubleshooting."
    ["emcomm"]="Emergency communication procedures, ICS forms, and ARES/RACES operations."
    ["propagation"]="HF propagation, NVIS, solar indices, and band conditions."
    ["reference"]="Q-codes, phonetic alphabet, RST reports, and quick reference cards."
)

# Generate article list for a category
generate_category_list() {
    local category="$1"
    local category_dir="${CONTENT_DIR}/${category}"
    
    if [[ ! -d "$category_dir" ]]; then
        return
    fi
    
    local articles=$(find "$category_dir" -name "*.html" -type f | sort)
    
    if [[ -z "$articles" ]]; then
        echo "            <li><em>No articles yet</em></li>"
        return
    fi
    
    for article in $articles; do
        local filename=$(basename "$article")
        local title=$(grep -o '<title>[^<]*</title>' "$article" 2>/dev/null | sed 's/<[^>]*>//g' | sed 's/ - Ham Radio Encyclopedia//' || echo "$filename")
        
        # Fallback to filename if title extraction fails
        if [[ -z "$title" || "$title" == "$filename" ]]; then
            title=$(echo "$filename" | sed 's/\.html$//' | tr '-' ' ' | sed 's/\b\(.\)/\u\1/g')
        fi
        
        echo "            <li><a href=\"${category}/${filename}\">${title}</a></li>"
    done
}

# Generate the main index.html
generate_index() {
    log_info "Generating index.html..."
    
    cat > "${CONTENT_DIR}/index.html" << 'HEADER'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ham Radio Encyclopedia - EmComm-Tools</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <header class="main-header">
        <h1>📻 Ham Radio Encyclopedia</h1>
        <p class="subtitle">Offline Reference for Amateur Radio Operators</p>
        <p class="version">EmComm-Tools Edition</p>
    </header>
    
    <main class="index-content">
        <section class="intro">
            <p>Welcome to the Ham Radio Encyclopedia, your comprehensive offline reference 
            for amateur radio. This resource is designed to be available when you need it 
            most—during emergencies when internet access may be unavailable.</p>
        </section>
        
        <nav class="category-grid">
HEADER

    # Generate category sections
    for category in ${CATEGORIES}; do
        local name="${CATEGORY_NAMES[$category]}"
        local desc="${CATEGORY_DESC[$category]}"
        
        cat >> "${CONTENT_DIR}/index.html" << EOF
            <section class="category-card" id="${category}">
                <h2>${name}</h2>
                <p>${desc}</p>
                <ul class="article-list">
$(generate_category_list "$category")
                </ul>
            </section>
            
EOF
    done

    cat >> "${CONTENT_DIR}/index.html" << 'FOOTER'
        </nav>
        
        <section class="quick-links">
            <h2>🔗 Quick Links</h2>
            <div class="link-grid">
                <a href="reference/phonetic-alphabet.html" class="quick-link">Phonetic Alphabet</a>
                <a href="reference/q-code.html" class="quick-link">Q-Codes</a>
                <a href="bandplans/amateur-radio-frequency-allocations.html" class="quick-link">Band Plan</a>
                <a href="digital-modes/ft8.html" class="quick-link">FT8 Guide</a>
            </div>
        </section>
    </main>
    
    <footer class="main-footer">
        <p>Part of <a href="https://emcomm-tools.ca">EmComm-Tools</a> | 
        Content licensed under <a href="https://creativecommons.org/licenses/by-sa/4.0/">CC BY-SA 4.0</a></p>
        <p class="build-info">Build: BUILDDATE</p>
    </footer>
</body>
</html>
FOOTER

    # Replace build date placeholder
    sed -i "s/BUILDDATE/${BUILD_DATE}/" "${CONTENT_DIR}/index.html"
    
    log_info "Index page generated."
}

generate_index
