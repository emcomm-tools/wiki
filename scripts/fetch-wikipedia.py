#!/usr/bin/env python3
"""
Fetch Wikipedia articles with images for EmComm-Tools Ham Radio Wiki
Author: Sylvain Deguire (VA2OPS)
Date: January 2025
"""

import json
import html
import re
import sys
import os
import urllib.request
import urllib.parse
import hashlib
import time

def download_image(url, images_dir):
    """Download image and return local filename"""
    try:
        # Clean up URL
        if url.startswith('//'):
            url = 'https:' + url
        elif url.startswith('/'):
            url = 'https://en.wikipedia.org' + url
        
        # Create filename from URL hash
        url_hash = hashlib.md5(url.encode()).hexdigest()[:12]
        
        # Get extension from URL
        parsed_path = urllib.parse.urlparse(url).path
        ext = os.path.splitext(parsed_path)[1].lower().split('?')[0]
        if ext not in ['.jpg', '.jpeg', '.png', '.gif', '.webp']:
            ext = '.png'
        
        local_filename = f"img_{url_hash}{ext}"
        local_path = os.path.join(images_dir, local_filename)
        
        # Skip if already downloaded
        if os.path.exists(local_path):
            return local_filename
        
        # Download with headers to avoid 403
        headers = {
            'User-Agent': 'EmComm-Tools-Wiki/1.0 (https://emcomm-tools.ca; Educational use)',
            'Accept': 'image/*'
        }
        req = urllib.request.Request(url, headers=headers)
        
        with urllib.request.urlopen(req, timeout=15) as response:
            content = response.read()
            # Only save if it's a reasonable size (> 500B, < 5MB)
            if 500 < len(content) < 5000000:
                with open(local_path, 'wb') as f:
                    f.write(content)
                return local_filename
    except Exception as e:
        # Silent fail for images
        pass
    
    return None


def fetch_article(title, output_file, images_dir):
    """Fetch a Wikipedia article and download its images"""
    
    api_url = f"https://en.wikipedia.org/w/api.php?action=parse&page={title}&format=json&prop=text&disableeditsection=true&disabletoc=false"
    
    print(f"[INFO] Fetching: {title}")
    
    try:
        headers = {
            'User-Agent': 'EmComm-Tools-Wiki/1.0 (https://emcomm-tools.ca; Educational use)',
        }
        req = urllib.request.Request(api_url, headers=headers)
        
        with urllib.request.urlopen(req, timeout=30) as response:
            data = json.loads(response.read().decode('utf-8'))
        
        if "error" in data:
            print(f"[WARN] Article not found: {title}")
            return False
        
        content = data['parse']['text']['*']
        page_title = data['parse']['title']
        
        # Find all image URLs
        img_pattern = r'src="(//upload\.wikimedia\.org[^"]*)"'
        matches = re.findall(img_pattern, content)
        
        downloaded = 0
        for img_url in matches:
            # Skip tiny thumbnails (less than 100px)
            if '/thumb/' in img_url:
                match = re.search(r'/(\d+)px-', img_url)
                if match and int(match.group(1)) < 100:
                    continue
            
            local_file = download_image(img_url, images_dir)
            if local_file:
                # Replace URL in content with local path
                content = content.replace(f'src="{img_url}"', f'src="../images/{local_file}"')
                downloaded += 1
                time.sleep(0.1)  # Small delay between images
        
        # Remove srcset (causes issues with local files)
        content = re.sub(r'\s*srcset="[^"]*"', '', content)
        
        # Clean up Wikipedia-specific elements
        content = re.sub(r'<span class="mw-editsection">.*?</span>', '', content, flags=re.DOTALL)
        content = re.sub(r'href="/wiki/', 'href="', content)
        
        # Remove broken image references
        content = re.sub(r'<img[^>]*src="//[^"]*"[^>]*/?>', '', content)
        content = re.sub(r'<img[^>]*src="/[^"]*"[^>]*/?>', '', content)
        
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
        
        # Ensure directory exists
        os.makedirs(os.path.dirname(output_file), exist_ok=True)
        
        with open(output_file, "w", encoding="utf-8") as f:
            f.write(html_output)
        
        print(f"  Saved: {output_file} ({downloaded} images)")
        return True
        
    except Exception as e:
        print(f"[ERROR] Failed to fetch {title}: {e}")
        return False


# Category mapping
CATEGORY_MAP = {
    "Amateur_radio": "reference",
    "Amateur_radio_operator": "reference",
    "Amateur_radio_licensing": "reference",
    "Call_sign": "reference",
    "ITU_prefix": "reference",
    "Amateur_radio_frequency_allocations": "bandplans",
    "Shortwave_bands": "bandplans",
    "High_frequency": "bandplans",
    "Very_high_frequency": "bandplans",
    "Ultra_high_frequency": "bandplans",
    "Radio_propagation": "propagation",
    "Skywave": "propagation",
    "Ground_wave": "propagation",
    "Near_vertical_incidence_skywave": "propagation",
    "Sporadic_E_propagation": "propagation",
    "Tropospheric_propagation": "propagation",
    "Ionosphere": "propagation",
    "Solar_cycle": "propagation",
    "Sunspot": "propagation",
    "Grey_line_(radio)": "propagation",
    "Antenna_(radio)": "antennas",
    "Dipole_antenna": "antennas",
    "Yagi-Uda_antenna": "antennas",
    "Vertical_antenna_(radio)": "antennas",
    "Loop_antenna": "antennas",
    "Random_wire_antenna": "antennas",
    "Balun": "antennas",
    "Antenna_tuner": "antennas",
    "Feed_line": "antennas",
    "G5RV_antenna": "antennas",
    "Standing_wave_ratio": "electronics",
    "Impedance_matching": "electronics",
    "Coaxial_cable": "electronics",
    "RF_connector": "electronics",
    "Ohm%27s_law": "electronics",
    "Decibel": "electronics",
    "Electronic_filter": "electronics",
    "Low-pass_filter": "electronics",
    "Dummy_load": "electronics",
    "Power_supply": "electronics",
    "Smith_chart": "electronics",
    "Electromagnetic_spectrum": "electronics",
    "FT8": "digital-modes",
    "PSK31": "digital-modes",
    "Radioteletype": "digital-modes",
    "Packet_radio": "digital-modes",
    "AX.25": "digital-modes",
    "Morse_code": "digital-modes",
    "WSJT_(amateur_radio_software)": "software",
    "Fldigi": "software",
    "Winlink": "software",
    "Software-defined_radio": "software",
    "RTL-SDR": "software",
    "Automatic_Packet_Reporting_System": "software",
    "Transceiver": "radios",
    "Amateur_radio_repeater": "radios",
    "Icom": "radios",
    "Yaesu_(brand)": "radios",
    "Kenwood_Corporation": "radios",
    "Amateur_radio_emergency_communications": "emcomm",
    "Amateur_Radio_Emergency_Service": "emcomm",
    "Radio_Amateur_Civil_Emergency_Service": "emcomm",
    "NATO_phonetic_alphabet": "reference",
    "Q_code": "reference",
    "RST_code": "reference",
    "QSO": "reference",
    "Contesting": "reference",
    "QRP_operation": "reference",
    "Amateur_satellite": "reference",
    "OSCAR": "reference",
}

ARTICLES = [
    "Amateur_radio",
    "Amateur_radio_operator",
    "Amateur_radio_licensing",
    "Call_sign",
    "ITU_prefix",
    "Amateur_radio_frequency_allocations",
    "Shortwave_bands",
    "High_frequency",
    "Very_high_frequency",
    "Ultra_high_frequency",
    "Radio_propagation",
    "Skywave",
    "Ground_wave",
    "Near_vertical_incidence_skywave",
    "Sporadic_E_propagation",
    "Tropospheric_propagation",
    "Ionosphere",
    "Solar_cycle",
    "Sunspot",
    "Grey_line_(radio)",
    "Antenna_(radio)",
    "Dipole_antenna",
    "Yagi-Uda_antenna",
    "Vertical_antenna_(radio)",
    "Loop_antenna",
    "Random_wire_antenna",
    "Balun",
    "Antenna_tuner",
    "Feed_line",
    "G5RV_antenna",
    "Standing_wave_ratio",
    "Impedance_matching",
    "Coaxial_cable",
    "RF_connector",
    "Ohm%27s_law",
    "Decibel",
    "Electronic_filter",
    "Low-pass_filter",
    "Dummy_load",
    "Power_supply",
    "Smith_chart",
    "Electromagnetic_spectrum",
    "FT8",
    "PSK31",
    "Radioteletype",
    "Packet_radio",
    "AX.25",
    "Morse_code",
    "WSJT_(amateur_radio_software)",
    "Fldigi",
    "Winlink",
    "Software-defined_radio",
    "RTL-SDR",
    "Automatic_Packet_Reporting_System",
    "Transceiver",
    "Amateur_radio_repeater",
    "Icom",
    "Yaesu_(brand)",
    "Kenwood_Corporation",
    "Amateur_radio_emergency_communications",
    "Amateur_Radio_Emergency_Service",
    "Radio_Amateur_Civil_Emergency_Service",
    "NATO_phonetic_alphabet",
    "Q_code",
    "RST_code",
    "QSO",
    "Contesting",
    "QRP_operation",
    "Amateur_satellite",
    "OSCAR",
]


def main():
    content_dir = "content/articles"
    images_dir = os.path.join(content_dir, "images")
    
    # Create directories
    os.makedirs(images_dir, exist_ok=True)
    for cat in ["bandplans", "digital-modes", "software", "radios", "antennas", 
                "electronics", "emcomm", "propagation", "reference"]:
        os.makedirs(os.path.join(content_dir, cat), exist_ok=True)
    
    print(f"[INFO] Starting Wikipedia fetch with images...")
    print(f"[INFO] Total articles: {len(ARTICLES)}")
    
    fetched = 0
    failed = 0
    
    for article in ARTICLES:
        category = CATEGORY_MAP.get(article, "reference")
        filename = article.lower().replace('_', '-').replace('%27', '').replace('%e2%80%93', '-')
        filename = re.sub(r'[^a-z0-9-]', '', filename)
        output_path = os.path.join(content_dir, category, f"{filename}.html")
        
        if fetch_article(article, output_path, images_dir):
            fetched += 1
        else:
            failed += 1
        
        time.sleep(1)  # Be nice to Wikipedia
    
    # Count images
    img_count = len([f for f in os.listdir(images_dir) if os.path.isfile(os.path.join(images_dir, f))])
    
    print(f"\n[INFO] Fetch complete: {fetched} articles, {failed} failed, {img_count} images")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        # Fetch single article
        title = sys.argv[1]
        category = CATEGORY_MAP.get(title, "reference")
        content_dir = "content/articles"
        images_dir = os.path.join(content_dir, "images")
        os.makedirs(images_dir, exist_ok=True)
        os.makedirs(os.path.join(content_dir, category), exist_ok=True)
        
        filename = title.lower().replace('_', '-').replace('%27', '').replace('%e2%80%93', '-')
        filename = re.sub(r'[^a-z0-9-]', '', filename)
        output_path = os.path.join(content_dir, category, f"{filename}.html")
        
        fetch_article(title, output_path, images_dir)
    else:
        main()
