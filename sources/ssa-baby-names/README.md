# SSA Baby Names Source Data

**Source:** [Social Security Administration - Baby Names](https://www.ssa.gov/oact/babynames/)

**License:** CC0 (Public Domain)

## Download

```bash
cd sources/ssa-baby-names
wget -O names.zip "https://www.ssa.gov/oact/babynames/names.zip"
unzip names.zip
```

Note: The SSA website may block requests without a browser user-agent. `wget` typically works.

## Format

Files are named `yobYYYY.txt` (year of birth) from 1880-present.

Each line: `name,gender,count`

Example:
```
Mary,F,7065
John,M,9655
```

## Processing

Run `ruby scripts/parse_ssa_names.rb` to merge SSA data with `data/en/given.txt`.

This adds:
- New names not in the base dataset
- Updated frequency scores based on total historical usage
- Era tags (`vintage` for 1880-1940 peaks, `modern` for 1980+ peaks)
