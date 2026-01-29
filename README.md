# name-stuff

Culture-significant name lists for use in games, apps, and creative projects.

## Overview

This project provides curated lists of given names (first names) and family names (surnames) organized by cultural/linguistic groups. Lists are available in multiple sizes to balance variety with download size.

**Use cases:**
- Procedural character generation in games
- Test data generation
- Creative writing aids
- Any project needing culturally-aware name lists

## Quick Start

### Direct Download

Lists are available as plain text files. Use the raw GitHub URL:

```
https://raw.githubusercontent.com/JohnCrafton/name-stuff/main/lists/{culture}/{type}_{tier}.txt
```

**Example:** English given names (small list, raw format):
```
https://raw.githubusercontent.com/JohnCrafton/name-stuff/main/lists/en/given_sm_raw.txt
```

### DragonRuby Example

```ruby
NAMES_URL = 'https://raw.githubusercontent.com/JohnCrafton/name-stuff/main/lists/en/given_sm_raw.txt'
NAMES_CACHE = 'data/names_cache.txt'

def fetch_names(args)
  # Check local cache first
  if args.gtk.read_file(NAMES_CACHE)
    args.state.given_names = args.gtk.read_file(NAMES_CACHE).split("\n")
    args.state.names_loaded = true
    return
  end

  # Fetch from network only if not cached
  unless args.state.names_loaded
    args.gtk.http_get(NAMES_URL, :names_callback)
    args.state.names_loaded = :loading
  end
end

def names_callback(args, response)
  if response[:complete] && response[:http_response_code] == 200
    # Save to local cache so we never fetch again
    args.gtk.write_file(NAMES_CACHE, response[:response_data])
    args.state.given_names = response[:response_data].split("\n")
    args.state.names_loaded = true
  end
end

def random_name(args)
  args.state.given_names.sample
end
```

## Responsible Use

This project uses GitHub's raw file hosting. Please use it responsibly:

**Do:**
- Fetch once and cache locally (as shown in the DragonRuby example above)
- Bundle name lists with your application after initial development
- Use the `sm` tier for most use cases (~100 names is plenty for variety)

**Don't:**
- Fetch on every app launch without caching
- Make repeated requests in loops
- Use this as a real-time API for high-traffic applications

**For high-volume needs:**
- Clone this repository and self-host
- Download files and bundle with your distribution
- Mirror to your own CDN

**Rate Limits:** GitHub may throttle or block IPs that make excessive requests. Abusive usage patterns risk being banned from GitHub's CDN entirely. We cannot control GitHub's enforcement, so please fetch responsibly.

**No API key required** — we trust the community to use this resource respectfully. If abuse becomes a problem, we may need to revisit this policy.

## Available Cultures

| Code | Name | Given Names | Family Names |
|------|------|:-----------:|:------------:|
| `en` | English | 5,071 | 162,254 |
| `de` | German | 5,738 | 50 |
| `es` | Spanish | 1,645 | 153 |
| `fr` | French | 2,565 | 79 |
| `it` | Italian | 3,235 | 100 |
| `pt` | Portuguese | 1,041 | 60 |
| `nl` | Dutch | 3,302 | 27 |
| `pl` | Polish | 359 | 20 |
| `ru` | Russian | 1,078 | 50 |
| `nordic` | Nordic (IS, DK, NO, SE, FI) | 3,773 | 79 |
| `baltic` | Baltic (EE, LV, LT) | 2,494 | 56 |
| `slavic` | Slavic (CZ, SK, HU, RO, etc.) | 7,230 | 241 |
| `greek` | Greek | 778 | 7 |
| `albanian` | Albanian | 1,748 | 45 |
| `caucasus` | Caucasus (AM, AZ, GE) | 1,418 | 52 |
| `turkic` | Turkic (TR, KZ) | 2,629 | 53 |
| `arab` | Arabic | 2,025 | - |
| `hebrew` | Hebrew | 1,067 | 42 |
| `chinese` | Chinese | 7,334 | 98 |
| `indian` | Indian | 1,455 | 84 |
| `japanese` | Japanese | 1,384 | 110 |
| `korean` | Korean | 1,376 | 137 |
| `vietnamese` | Vietnamese | 307 | 44 |

## Size Tiers

| Tier | Description | Typical Size |
|------|-------------|--------------|
| `sm` | Small - most popular names | ~100 |
| `lg` | Large - broader selection | ~1/3 of full |
| `xl` | Extra Large - complete list | All available |

## File Formats

### With Metadata (default)

```
# name-stuff given names for culture: en
# format: name|gender|frequency|tags
Aaron|M|6|
Abigail|F|5|
```

**Gender codes:**
- `M` = Male
- `F` = Female
- `U` = Unisex
- `M?` = Mostly male
- `F?` = Mostly female

**Frequency:** 1-13 scale (higher = more common)

### Raw Format (`_raw` suffix)

Names only, one per line:
```
Aaron
Abigail
```

### ASCII Format (`_ascii` suffix)

Unicode characters transliterated to ASCII equivalents:
- `Ångström` → `Angstrom`
- `José` → `Jose`

### Combined (`_raw_ascii` suffix)

Raw names in ASCII-safe format.

## URL Pattern

```
lists/{culture}/{type}_{tier}{format}.txt
```

Where:
- `{culture}` = Culture code (e.g., `en`, `es`, `japanese`)
- `{type}` = `given` or `family`
- `{tier}` = `sm`, `lg`, or `xl`
- `{format}` = (empty), `_raw`, `_ascii`, or `_raw_ascii`

**Examples:**
- `lists/en/given_sm.txt` - English given names, small, with metadata
- `lists/es/family_xl_raw.txt` - Spanish surnames, full list, raw format
- `lists/japanese/given_lg_ascii.txt` - Japanese given names, large, ASCII

## Project Structure

```
name-stuff/
├── LICENSE              # CC-BY-NC-SA 4.0
├── README.md
├── manifest.json        # Machine-readable metadata
├── sources/             # Original source data (for reference)
├── data/                # Processed full datasets
│   └── {culture}/
│       ├── given.txt
│       └── family.txt
├── lists/               # Generated downloadable lists
│   └── {culture}/
│       ├── given_sm.txt
│       ├── given_lg.txt
│       ├── given_xl.txt
│       └── ...
├── scripts/             # Build scripts
└── skips/               # Community-reviewed omissions
```

## Data Sources

1. **Given Names:** Derived from [gender.c](http://www.heise.de/ct/ftp/07/17/182/) name dictionary
   - Original: GNU Free Documentation License 1.2+
   - ~48,000 names across 54 countries with frequency data

2. **US Surnames:** [US Census Bureau 2010](https://www.census.gov/topics/population/genealogy/data/2010_surnames.html)
   - Public Domain (US Government work)
   - 162,254 surnames with frequency data

3. **International Surnames:** [popular-names-by-country-dataset](https://github.com/sigpwned/popular-names-by-country-dataset)
   - CC0 (Public Domain dedication)
   - 2,278 surnames from 75 countries

## Building

Requires Ruby 2.7+.

```bash
# Parse source data
ruby scripts/parse_given_names.rb
ruby scripts/parse_census_surnames.rb
ruby scripts/parse_international_surnames.rb

# Generate all list tiers and formats
ruby scripts/generate_lists.rb
ruby scripts/generate_lists.rb --raw
ruby scripts/generate_lists.rb --ascii
ruby scripts/generate_lists.rb --raw --ascii
```

## Community Guidelines

This project aims to be respectful of all cultures. We maintain a list of names that have been flagged for review by the community. If you believe a name should be added to or removed from this list, please open an issue.

## Contributing

Contributions welcome! Especially:
- Additional surname data for underrepresented cultures
- Corrections to transliterations
- Literary/historical name tagging
- Bug reports and improvements

## License

**CC-BY-NC-SA 4.0** (Creative Commons Attribution-NonCommercial-ShareAlike 4.0)

You are free to:
- **Share** — copy and redistribute the material
- **Adapt** — remix, transform, and build upon the material

Under these terms:
- **Attribution** — Give appropriate credit
- **NonCommercial** — Not for commercial purposes
- **ShareAlike** — Distribute contributions under the same license

See [LICENSE](LICENSE) for full details.
