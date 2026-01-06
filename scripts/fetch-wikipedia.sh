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
    ["Amateur_radio"]="reference"
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
    ["Antenna_(radio)"]="antennas"
    ["Dipole_antenna"]="antennas"
    ["Yagi%E2%80%93Uda_antenna"]="antennas"
    ["Vertical_antenna"]="antennas"
    ["Loop_antenna"]="antennas"
    ["End-fed_antenna"]="antennas"
    ["Balun"]="antennas"
    ["Standing_wave_ratio"]="electronics"
    ["Impedance_matching"]="electronics"
    ["Coaxial_cable"]="electronics"
    ["RF_connector"]="electronics"
    ["Ohm%27s_law"]="electronics"
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
    ["Amateur_radio_emergency_communications"]="emcomm"
    ["Phonetic_alphabet"]="reference"
    ["Q_code"]="reference"
    ["RST_code"]="reference"
    ["QSO"]="reference"
    ["Call_sign"]="reference"
    ["Amateur_radio_licensing"]="reference"
    ["Amateur_radio_operator"]="reference"
    ["Ham_radio_contesting"]="reference"
)

# Fetch a single article from Wikipedia
fetch_article() {
    local title="$1"
    local output_file="$2"
    
    log_info "Fetching: ${title}"
    
    # Use Wikipedia API to get HTML content
    local api_url="${WIKIPEDIA_API}?action=parse&page=${title}&format=json&prop=text&disableeditsection=true&disabletoc=false"
    
    # Save response to temp file
    local response_file="${TEMP_DIR}/response.json"
    
    if ! curl -s "${api_url}" -o "${response_file}"; then
        log_warn "Failed to fetch: ${title}"
        return 1
    fi
    
    # Check if article exists (look for error in response)
    if grep -q '"error"' "${response_file}"; then
        log_warn "Article not found: ${title}"
        return 1
    fi
    
    # Process with Python using the temp file
    python3 << EOF
import json
import html
import re
import sys

try:
    with open("${response_file}", "r", encoding="utf-8") as f:
        parsed = json.load(f)
    
    if "error" in parsed:
        print(f"Error: {parsed['error']}", file=sys.stderr)
        sys.exit(1)
    
    content = parsed['parse']['text']['*']
    page_title = parsed['parse']['title']
    
    # Clean up Wikipedia-specific elements
    content = re.sub(r'<span class="mw-editsection">.*?</span>', '', content, flags=re.DOTALL)
    content = re.sub(r'href="/wiki/', 'href="', content)
    content = re.sub(r'href="//upload.wikimedia.org', 'href="https://upload.wikimedia.org', content)
    
    html_output = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{html.escape(page_title)} - Ham Radio Encyclopedia</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <nav class="breadcrumb">
        <a href="../index.html">Home</a> &gt; {html.escape(page_title)}
    </nav>
    <article>
        <h1>{html.escape(page_title)}</h1>
        {content}
        <footer class="attribution">
            <p>Content from <a href="https://en.wikipedia.org/wiki/{page_title.replace(' ', '_')}">Wikipedia</a>, 
            licensed under <a href="https://creativecommons.org/licenses/by-sa/4.0/">CC BY-SA 4.0</a>.</p>
        </footer>
    </article>
    <nav class="bottom-nav">
        <a href="../index.html">← Back to Index</a>
    </nav>
</body>
</html>'''
    
    with open("${output_file}", "w", encoding="utf-8") as f:
        f.write(html_output)
    
    print(f"  Saved: ${output_file}")
    
except Exception as e:
    print(f"Error processing: {e}", file=sys.stderr)
    sys.exit(1)
EOF
    
    return $?
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
    log_info "Total articles to fetch: ${#WIKIPEDIA_ARTICLES[@]}"
    
    # Create category directories
    for cat in ${CATEGORIES}; do
        mkdir -p "${CONTENT_DIR}/${cat}"
    done
    
    # Track statistics
    local fetched=0
    local failed=0
    
    # Fetch each article (iterate over array properly)
    for article in "${WIKIPEDIA_ARTICLES[@]}"; do
        # Skip empty entries
        [[ -z "$article" ]] && continue
        
        local category=$(get_category "$article")
        local filename=$(echo "$article" | tr '[:upper:]' '[:lower:]' | tr '_' '-' | tr -cd '[:alnum:]-')
        local output_path="${CONTENT_DIR}/${category}/${filename}.html"
        
        if fetch_article "$article" "$output_path"; then
            fetched=$((fetched + 1))
        else
            failed=$((failed + 1))
        fi
        
        # Be nice to Wikipedia servers
        sleep 1
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
