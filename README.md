# EmComm-Tools Ham Radio Encyclopedia

A comprehensive offline Ham Radio reference in ZIM format for use with EmComm-Tools OS.

## Overview

This project builds a searchable, offline encyclopedia for amateur radio operators. The resulting ZIM file can be viewed with Kiwix (included in EmComm-Tools) and provides critical reference material when internet connectivity is unavailable during emergencies or field operations.

**Current Build:** 33 articles, ~150 KB HTML (~8 MB ZIM with images)

## Content Categories

### Emergency Communications (7 articles)
- **Radiogram Message Handling** - ARRL format, precedence, traffic handling
- **Net Operations Guide** - NCS duties, check-ins, tactical vs formal
- **Off-Grid Power Solutions** - Solar, batteries, generators for EmComm
- **Go-Kit Checklist** - Ready bag essentials for deployment
- **ICS Forms Guide** - FEMA forms for emergency management
- **Simplex Operations** - Non-repeater emergency communications
- **Battery & Charging Guide** - LiFePO4, sizing, solar charging

### Digital Modes (6 articles)
- **APRS Basics** - Position reporting, messaging, digipeaters
- **Winlink Setup Guide** - Email over radio configuration
- **JS8Call Operations** - HF messaging network procedures
- **Fldigi Digital Modes** - PSK, RTTY, Olivia, MT63, MFSK comprehensive guide
- **DMR & Digital Voice** - DMR, D-STAR, System Fusion basics

### Reference (16 articles)
- **Phonetic Alphabet** - NATO phonetics, numbers, prosigns
- **Ham Radio Math** - Formulas, decibels, Ohm's law, wavelength
- **Winlink Catalog Requests** - Position, weather, news services
- **Coax & Connectors** - Cable types, loss, connector pinouts
- **Troubleshooting Guide** - Systematic problem solving
- **Band Plan Quick Reference** - HF/VHF/UHF allocations with frequencies
- **HF Propagation Basics** - Ionosphere, MUF, skip, NVIS
- **Grounding & Lightning Safety** - Station grounding, surge protection
- **CW Reference** - Morse code, prosigns, abbreviations, RST
- **Repeater Etiquette** - Proper repeater operating practices
- **Space Weather & Propagation** - SFI, SSN, K-index, A-index explained
- **Satellite Operations** - FM/linear sats, tracking, Doppler
- **Log Keeping & QSL Cards** - Logging software, ADIF, LoTW, awards
- **Contest Operating Basics** - Exchanges, strategy, major contests
- **RFI Troubleshooting** - Finding and eliminating interference
- **VHF/UHF Weak Signal** - SSB, EME, meteor scatter, tropo
- **HF Portable Operating** - POTA, SOTA, field station setup

### Antennas (2 articles)
- **Field Expedient Antennas** - Dipoles, EFHW, verticals, construction
- **Antenna Theory Basics** - SWR, impedance, gain, patterns

### Software (1 article)
- **LinBPQ Commands** - BBS/Node sysop and user command reference

### Radios (1 article)
- **Radio Digital Settings** - 22 radios configured for digital modes

## Quick Start

### Using Pre-built ZIM

Download the latest ZIM from [Releases](https://github.com/emcomm-tools/wiki/releases):

```bash
# Copy to your wikipedia folder
cp emcomm-ham-wiki_*.zim ~/wikipedia/

# View with Kiwix desktop
kiwix-desktop ~/wikipedia/emcomm-ham-wiki_*.zim

# Or serve via web browser
kiwix-serve -p 8888 ~/wikipedia/emcomm-ham-wiki_*.zim
# Open http://localhost:8888
```

### Building from Source

**Requirements:**
- `zimwriterfs` (from zim-tools package)
- Bash shell

**Build:**
```bash
git clone https://github.com/emcomm-tools/wiki.git
cd wiki
./scripts/generate-index.sh   # Regenerate index from articles
./build.sh                    # Build ZIM file
# Output: output/emcomm-ham-wiki_YYYYMMDD.zim
```

## Project Structure

```
emcomm-tools-wiki/
├── README.md
├── LICENSE
├── build.sh                    # Main build script
├── config.sh                   # Configuration variables
├── scripts/
│   ├── generate-index.sh       # Build main index page
│   └── validate-content.sh     # Check for broken links
├── content/
│   └── articles/
│       ├── index.html          # Main landing page (auto-generated)
│       ├── css/
│       │   └── style.css       # Wiki styling
│       ├── images/             # Article images
│       ├── antennas/           # Antenna articles
│       ├── digital/            # Digital mode guides
│       ├── emcomm/             # Emergency communications
│       ├── radios/             # Radio configuration
│       ├── reference/          # Quick reference materials
│       └── software/           # Software guides
├── templates/
│   └── article.html            # Template for new articles
└── output/                     # Built ZIM files
```

## Adding Content

### New Articles

1. Create HTML file in appropriate `content/articles/` subdirectory
2. Follow existing article structure (breadcrumb, TOC, sections)
3. Use consistent CSS classes from `style.css`
4. Regenerate index and rebuild:

```bash
./scripts/generate-index.sh
./build.sh
```

### Article Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Article Title - Ham Radio Encyclopedia</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <nav class="breadcrumb">
        <a href="../index.html">Home</a> &gt; 
        <a href="../index.html#category">Category</a> &gt; 
        Article Title
    </nav>
    
    <article>
        <h1>Article Title</h1>
        <section class="summary">
            <p>Brief description of the article content.</p>
        </section>
        
        <!-- Content here -->
        
        <footer class="attribution">
            <p>Compiled for the EmComm-Tools Ham Radio Encyclopedia</p>
        </footer>
    </article>
</body>
</html>
```

## Installation in EmComm-Tools

The ZIM file is included in EmComm-Tools at `~/wikipedia/`. It integrates with the pre-installed Kiwix reader for offline access.

To update to a newer version:
```bash
cp output/emcomm-ham-wiki_*.zim ~/wikipedia/
```

## Use Cases

- **Emergency Operations** - Reference materials when internet is down
- **Field Day / POTA / SOTA** - Offline guides for portable operations
- **Training** - New ham education and Elmer resources
- **Quick Reference** - Frequencies, formulas, procedures at your fingertips
- **Remote/Rural Locations** - Full documentation without connectivity

## Contributing

Contributions welcome! Guidelines:

1. **Accuracy** - Verify technical information against authoritative sources
2. **Copyright** - Use only original content or CC-licensed materials
3. **Style** - Follow existing article structure and CSS conventions
4. **Testing** - Ensure ZIM builds successfully before submitting
5. **Images** - Place in `content/articles/images/`, optimize file size

### Submitting Changes

1. Fork the repository
2. Create feature branch (`git checkout -b add-new-article`)
3. Add/modify content
4. Test build (`./build.sh`)
5. Commit changes (`git commit -m 'Add article description'`)
6. Push and open Pull Request

## License

- **Code/Scripts**: MIT License
- **Original Content**: CC BY-SA 4.0 (Creative Commons Attribution-ShareAlike)
- **Wikipedia Content**: CC BY-SA 4.0 (attributed to Wikipedia contributors)

## Credits

- [EmComm-Tools Project](https://emcomm-tools.ca) - Linux distribution for amateur radio
- [Kiwix](https://kiwix.org) - Offline content reader
- [OpenZIM](https://openzim.org) - ZIM file format specification
- ARRL, RAC, and amateur radio community resources

## Author

Sylvain Deguire (VA2OPS)

## Links

- **Website**: [emcomm-tools.ca](https://emcomm-tools.ca)
- **GitHub**: [github.com/emcomm-tools](https://github.com/emcomm-tools)
- **Wiki Repo**: [github.com/emcomm-tools/wiki](https://github.com/emcomm-tools/wiki)

---

*Part of the [EmComm-Tools](https://github.com/emcomm-tools) project - Ham Radio Emergency Communications for Debian Linux*

**73 de VA2OPS** 📻
