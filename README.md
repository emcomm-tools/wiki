# EmComm-Tools Ham Radio Wiki

A comprehensive offline Ham Radio encyclopedia in ZIM format for use with EmComm-Tools OS.

## Overview

This project builds a searchable, offline reference library for amateur radio operators. The resulting ZIM file can be viewed with Kiwix (included in EmComm-Tools) and provides critical reference material when internet connectivity is unavailable during emergencies.

## Content Categories

- **Band Plans** - ITU regions, country allocations, mode segments
- **Digital Modes** - FT8, JS8Call, VARA, Winlink, RTTY, PSK31
- **Software Guides** - Quick-start guides for EmComm-Tools applications
- **Radio Profiles** - Digital mode settings for popular transceivers
- **Antennas** - Construction guides, formulas, wire lengths
- **Electronics** - Fundamentals for ham radio operators
- **EmComm Procedures** - ICS forms, ARES/RACES, net operations
- **Propagation** - HF characteristics, NVIS, solar indices
- **Quick Reference** - Q-codes, phonetics, frequencies, pinouts

## Requirements

- `zimwriterfs` (included in EmComm-Tools via zim-tools package)
- `curl` or `wget` for fetching Wikipedia content
- `python3` for content processing scripts

## Building the ZIM File

```bash
# Clone the repository
git clone https://github.com/emcomm-tools/wiki.git
cd wiki

# Build the ZIM file
./build.sh

# Output will be in: output/emcomm-ham-wiki_YYYYMMDD.zim
```

## Project Structure

```
emcomm-tools-wiki/
├── README.md
├── LICENSE
├── build.sh              # Main build script
├── config.sh             # Configuration variables
├── scripts/
│   ├── fetch-wikipedia.sh    # Extract ham radio articles from Wikipedia
│   ├── generate-index.sh     # Build main index page
│   └── validate-content.sh   # Check for broken links
├── content/
│   ├── articles/         # HTML article files
│   │   ├── index.html    # Main landing page
│   │   ├── bandplans/
│   │   ├── digital-modes/
│   │   ├── software/
│   │   ├── radios/
│   │   ├── antennas/
│   │   ├── electronics/
│   │   ├── emcomm/
│   │   ├── propagation/
│   │   └── reference/
│   ├── images/           # Icons, diagrams, schematics
│   └── css/
│       └── style.css     # Wiki styling
├── templates/
│   ├── article.html      # Article template
│   └── category.html     # Category listing template
└── output/               # Built ZIM files
```

## Adding Content

### Manual Articles

Create HTML files in the appropriate `content/articles/` subdirectory using the article template:

```bash
cp templates/article.html content/articles/antennas/dipole.html
# Edit the file with your content
```

### Wikipedia Extraction

The `scripts/fetch-wikipedia.sh` script can pull relevant articles from Wikipedia (CC BY-SA licensed):

```bash
./scripts/fetch-wikipedia.sh "Amateur_radio"
```

## Installation

Copy the built ZIM file to your EmComm-Tools wikipedia directory:

```bash
cp output/emcomm-ham-wiki_*.zim ~/wikipedia/
```

Then open Kiwix and add the library.

## Contributing

Contributions welcome! Please ensure:
- Content is accurate and well-sourced
- Respect copyright - use CC-licensed or original content only
- Follow the existing article structure
- Test that the ZIM builds successfully

## License

- **Code/Scripts**: MIT License
- **Content**: CC BY-SA 4.0 (Creative Commons Attribution-ShareAlike)

## Credits

- EmComm-Tools Project: https://emcomm-tools.ca
- Kiwix: https://kiwix.org
- OpenZIM: https://openzim.org

## Author

Sylvain Deguire (VA2OPS)
