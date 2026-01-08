# EmComm-Tools Ham Radio Encyclopedia

A comprehensive offline Ham Radio encyclopedia in ZIM format for use with EmComm-Tools OS.

## Overview

This project builds a searchable, offline reference library for amateur radio operators. The resulting ZIM file can be viewed with Kiwix (included in EmComm-Tools) and provides critical reference material when internet connectivity is unavailable during emergencies.

**Current Build:** 67+ articles | ~7 MB with images | Works offline

## Content Categories

- **Band Plans** - ITU regions, country allocations, mode segments
- **Digital Modes** - FT8, JS8Call, VARA, VarAC, ARDOP, Winlink, RTTY, PSK31
- **Software Guides** - Fldigi, Direwolf, Pat, YAAC, JS8Call, LinBPQ quick-starts
- **Radio Profiles** - Digital mode settings for 22+ radios, Digirig setup
- **Antennas** - Construction guides, formulas, wire lengths
- **Electronics** - Fundamentals for ham radio operators
- **EmComm Procedures** - ICS forms, ARES/RACES, net operations
- **Propagation** - HF characteristics, NVIS, solar indices
- **Quick Reference** - Q-codes, phonetics, frequencies, Winlink catalog commands

## Quick Start (Use Pre-built)

Download the latest ZIM from [SourceForge](https://sourceforge.net/projects/emcomm-tools/files/ZIM/) and open with Kiwix:

```bash
cp emcomm-ham-wiki_*.zim ~/wikipedia/
kiwix-desktop ~/wikipedia/emcomm-ham-wiki_*.zim
```

## Building from Source

### Requirements

- `zimwriterfs` (from zim-tools package)
- `curl` for fetching Wikipedia content
- `python3` for content processing

### Build Steps

```bash
# Clone the repository
git clone https://github.com/emcomm-tools/wiki.git
cd wiki

# Fetch Wikipedia articles (optional - content included)
python3 scripts/fetch-wikipedia.py

# Build the ZIM file
./build.sh

# Output: output/emcomm-ham-wiki_YYYYMMDD.zim
```

## Project Structure

```
emcomm-tools-wiki/
├── README.md
├── LICENSE
├── build.sh                    # Main build script
├── scripts/
│   ├── fetch-wikipedia.py      # Fetch articles from Wikipedia
│   ├── generate-index.sh       # Build main index page
│   └── validate-content.sh     # Check for broken links
├── content/
│   └── articles/
│       ├── index.html          # Main landing page
│       ├── css/
│       │   └── style.css       # Wiki styling
│       ├── images/             # Downloaded Wikipedia images
│       ├── bandplans/
│       ├── digital-modes/
│       ├── software/           # JS8Call, Pat, Fldigi, LinBPQ, etc.
│       ├── radios/             # Radio digital mode settings
│       ├── antennas/
│       ├── electronics/
│       ├── emcomm/
│       ├── propagation/
│       ├── reference/          # Winlink catalog, ICS forms, etc.
│       └── wikipedia/          # Fetched Wikipedia articles
├── templates/
│   └── article.html            # Template for new articles
└── output/                     # Built ZIM files (git-ignored)
```

## Adding Content

### Custom Articles

Create HTML files in the appropriate `content/articles/` subdirectory:

```bash
cp templates/article.html content/articles/software/my-guide.html
# Edit with your content
./scripts/generate-index.sh   # Update index
./build.sh                    # Rebuild ZIM
```

### Fetch More Wikipedia Articles

Edit `scripts/fetch-wikipedia.py` to add articles to the `ARTICLES` list, then:

```bash
python3 scripts/fetch-wikipedia.py Article_Name
```

## Installation in EmComm-Tools

The ZIM file is included in EmComm-Tools at `~/wikipedia/`. To update manually:

```bash
cp output/emcomm-ham-wiki_*.zim ~/wikipedia/
```

View with Kiwix (desktop app) or kiwix-serve (web):

```bash
kiwix-serve -p 8888 ~/wikipedia/emcomm-ham-wiki_*.zim
# Open http://localhost:8888
```

## Contributing

Contributions welcome! Please ensure:

1. Content is accurate and well-sourced
2. Use CC-licensed or original content only (respect copyright)
3. Follow existing article structure and CSS
4. Test that the ZIM builds successfully
5. Images go in `content/articles/images/`

### Submitting Changes

1. Fork the repository
2. Create your feature branch (`git checkout -b add-new-article`)
3. Commit your changes (`git commit -m 'Add IC-705 setup guide'`)
4. Push to the branch (`git push origin add-new-article`)
5. Open a Pull Request

## License

- **Code/Scripts**: MIT License
- **Original Content**: CC BY-SA 4.0 (Creative Commons Attribution-ShareAlike)
- **Wikipedia Content**: CC BY-SA 4.0 (attributed to Wikipedia contributors)

## Credits

| Contributor | Role |
|-------------|------|
| **Sylvain Deguire (VA2OPS)** | Project lead, EmComm-Tools Debian Edition |
| **Gaston Gonzalez (KT7RUN)** | Radio configurations, EmComm-Tools OS Community |
| **Bill Cremerius (PY2BIL/LU7ECX)** | BPQ commands reference |
| **John Wiseman (G8BPQ)** | LinBPQ/BPQ32 software |
| **Wikimedia Foundation** | Wikipedia article content |

### Resources

- [EmComm-Tools Project](https://emcomm-tools.ca)
- [Kiwix](https://kiwix.org) - Offline content viewer
- [OpenZIM](https://openzim.org) - ZIM file format

## Links

- **Website**: https://emcomm-tools.ca
- **GitHub**: https://github.com/emcomm-tools
- **SourceForge Downloads**: https://sourceforge.net/projects/emcomm-tools/files/ZIM/

---

*Part of the [EmComm-Tools](https://github.com/emcomm-tools) project - Ham Radio Emergency Communications for Linux*

**73 de VA2OPS**
