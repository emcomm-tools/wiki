#!/bin/bash
#
# Author  : Sylvain Deguire (VA2OPS)
# Date    : January 2025
# Purpose : Fetch ham radio articles from Wikipedia

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/.."

source ./config.sh

# Create temporary directory for processing
TEMP_DIR=$(mktemp -d)
trap "rm -rf ${TEMP_DIR}" EXIT

log_info() {
    echo "[INFO] $1"
}

log_warn() {
    echo "[WARN] $1"
}

# Category mapping for organizing articles
declare -A CATEGORY_MAP
CATEGORY_MAP=(
    ["Amateur_radio_frequency_allocations"]="bandplans"
    ["Shortwave_bands"]="bandplans"
    ["High_frequency"]="bandplans"
    ["Very_high_frequency"]="bandplans"
    ["Ultra_high_frequency"]="bandplans"
    ["Radio_propagation"]="propagation"
    ["Skywave"]="propagation"
    ["Ground_wave"]="propagation"
    ["Near_vertical_incidence_skywave"]="propagation"
    ["Sporadic_E_propagation"]="propagation"
    ["Tropospheric_propagation"]="propagation"
    ["Ionosphere"]="propagation"
    ["Solar_cycle"]="propagation"
    ["Sunspot"]="propagation"
    ["K-index"]="propagation"
    ["A-index"]="propagation"
    ["Solar_flux_unit"]="propagation"
    ["Antenna_(radio)"]="antennas"
    ["Dipole_antenna"]="antennas"
    ["Yagi-Uda_antenna"]="antennas"
    ["Vertical_antenna"]="antennas"
    ["Loop_antenna"]="antennas"
    ["End-fed_antenna"]="antennas"
    ["Balun"]="antennas"
    ["Standing_wave_ratio"]="electronics"
    ["Impedance_matching"]="electronics"
    ["Coaxial_cable"]="electronics"
    ["RF_connector"]="electronics"
    ["Ohms_law"]="electronics"
    ["Decibel"]="electronics"
    ["Electronic_filter"]="electronics"
    ["Low-pass_filter"]="electronics"
    ["Dummy_load"]="electronics"
    ["Power_supply"]="electronics"
    ["FT8"]="digital-modes"
    ["FT4_(amateur_radio_mode)"]="digital-modes"
    ["PSK31"]="digital-modes"
    ["RTTY"]="digital-modes"
    ["Digital_mode_(amateur_radio)"]="digital-modes"
    ["Packet_radio"]="digital-modes"
    ["AX.25"]="digital-modes"
    ["JS8Call"]="software"
    ["WSJT-X"]="software"
    ["Fldigi"]="software"
    ["Direwolf_(software)"]="software"
    ["Winlink"]="software"
    ["Software-defined_radio"]="software"
    ["RTL-SDR"]="software"
    ["Automatic_Packet_Reporting_System"]="software"
    ["Transceiver"]="radios"
    ["Amateur_radio_transceiver"]="radios"
    ["Icom"]="radios"
    ["Yaesu_(brand)"]="radios"
    ["Kenwood_Corporation"]="radios"
    ["Sound_card_interface"]="radios"
    ["CAT_(Computer_Aided_Transceiver)"]="radios"
    ["Amateur_radio_emergency_communications"]="emcomm"
    ["Phonetic_alphabet"]="reference"
    ["Q_code"]="reference"
    ["RST_code"]="reference"
    ["QSO"]="reference"
    ["Call_sign"]="reference"
    ["Amateur_radio_licensing"]="reference"
    ["Ham_radio_contesting"]="reference"
)

# Fetch a single article from Wikipedia
fetch_article() {
    local title="$1"
    local output_file="$2"
    
    log_info "Fetching: ${title}"
    
    # Use Wikipedia API to get HTML content
    local api_url="${WIKIPEDIA_API}?action=parse&page=${title}&format=json&prop=text&disableeditsection=true&disabletoc=false"
    
    local response=$(curl -s "${api_url}")
    
    # Check if article exists
    if echo "${response}" | grep -q '"error"'; then
        log_warn "Article not found: ${title}"
        return 1
    fi
    
    # Extract HTML content using Python (more reliable than jq for complex JSON)
    python3 << EOF > "${output_file}"
import json
import sys
import html
import re

data = '''${response}'''
try:
    parsed = json.loads(data)
    content = parsed['parse']['text']['*']
    title = parsed['parse']['title']
    
    # Clean up Wikipedia-specific elements
    # Remove edit links, citations that won't work offline
    content = re.sub(r'<span class="mw-editsection">.*?</span>', '', content)
    content = re.sub(r'href="/wiki/', 'href="', content)
    content = re.sub(r'href="//upload.wikimedia.org', 'href="https://upload.wikimedia.org', content)
    
    print(f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{html.escape(title)} - Ham Radio Encyclopedia</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <nav class="breadcrumb">
        <a href="../index.html">Home</a> &gt; {html.escape(title)}
    </nav>
    <article>
        <h1>{html.escape(title)}</h1>
        {content}
        <footer class="attribution">
            <p>Content from <a href="https://en.wikipedia.org/wiki/{title.replace(' ', '_')}">Wikipedia</a>, 
            licensed under <a href="https://creativecommons.org/licenses/by-sa/4.0/">CC BY-SA 4.0</a>.</p>
        </footer>
    </article>
    <nav class="bottom-nav">
        <a href="../index.html">← Back to Index</a>
    </nav>
</body>
</html>''')
except Exception as e:
    print(f"Error processing {title}: {e}", file=sys.stderr)
    sys.exit(1)
EOF
    
    return 0
}

# Get category for an article
get_category() {
    local title="$1"
    local category="${CATEGORY_MAP[$title]}"
    
    if [[ -z "$category" ]]; then
        category="reference"  # Default category
    fi
    
    echo "$category"
}

# Main fetch process
main() {
    log_info "Starting Wikipedia article fetch..."
    
    # Create category directories
    for cat in ${CATEGORIES}; do
        mkdir -p "${CONTENT_DIR}/${cat}"
    done
    
    # Track statistics
    local fetched=0
    local failed=0
    
    # Fetch each article
    for article in ${WIKIPEDIA_ARTICLES}; do
        # Skip empty lines
        [[ -z "$article" ]] && continue
        
        local category=$(get_category "$article")
        local filename=$(echo "$article" | tr '[:upper:]' '[:lower:]' | tr '_' '-' | tr -cd '[:alnum:]-')
        local output_path="${CONTENT_DIR}/${category}/${filename}.html"
        
        if fetch_article "$article" "$output_path"; then
            ((fetched++))
        else
            ((failed++))
        fi
        
        # Be nice to Wikipedia servers
        sleep 0.5
    done
    
    log_info "Fetch complete: ${fetched} articles fetched, ${failed} failed"
}

# Allow fetching a single article
if [[ -n "$1" ]]; then
    category=$(get_category "$1")
    mkdir -p "${CONTENT_DIR}/${category}"
    filename=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr '_' '-' | tr -cd '[:alnum:]-')
    fetch_article "$1" "${CONTENT_DIR}/${category}/${filename}.html"
else
    main
fi
