# Roscher's Lexicon of Mythology Index

**Source:** [Zenodo Record 11113695](https://zenodo.org/records/11113695)

**License:** CC0 1.0 Universal (Public Domain)

**Compiler:** Jonathan Groß

## About

This index was created from Wilhelm Heinrich Roscher's "Detailed Lexicon of Greek and Roman Mythology" (Ausführliches Lexikon der griechischen und römischen Mythologie), originally published 1884-1937.

Roscher's Lexicon is the most complete resource on Greek and Roman mythological names and also encompasses mythological subjects from Sumerian, Akkadian, Babylonian, Hittite, Egyptian, Celtic, Germanic and other neighboring cultures.

## Files

- `RLM_Index_tab_A.csv` - Main alphabet entries (~15,000 entries)
- `RLM_Index_tab_B.csv` - Cover addenda entries
- `README.txt` - Original documentation from the dataset

## Processing

Run `ruby scripts/parse_roscher_mythology.rb` to tag matching names in all culture files with `mythological`.

This script:
1. Extracts names from entity types: deity, character, nymph, centaur, satyr, creature, hybrid
2. Scans all `data/{culture}/given.txt` files
3. Adds the `mythological` tag to matching names

## Entity Types Included

- `deity` - Gods and goddesses
- `character` - Heroes, mortals, mythological figures
- `nymph` - Nature spirits
- `collective_deity` - Groups of gods
- `centaur` - Half-horse creatures
- `satyr` - Forest spirits
- `creature` - Mythological beasts
- `hybrid` - Mixed-form beings
