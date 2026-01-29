# Community-Reviewed Name Omissions

This directory contains names that have been flagged by the community for omission from generated lists. The goal is to ensure this project promotes respectful representation of all cultures.

## Philosophy

Names are deeply personal and cultural. While we aim to be comprehensive, we recognize that certain names may cause harm or offense when used in generated content. This is not censorship—the raw source data remains available—but rather a considered default for downstream consumers.

## Format

`skips.txt` contains one entry per line:

```
# Comments start with hash
NAME|reason
```

**Example:**
```
# Historical figures associated with atrocities
SomeName|historical-atrocity
```

## Categories

- `historical-atrocity` - Names strongly associated with historical atrocities
- `offensive-combination` - Names that form offensive phrases when combined
- `community-request` - Removed at community request with documented rationale

## Contributing

To request an addition or removal:

1. Open an issue describing the name and rationale
2. Community discussion will determine the outcome
3. All decisions are documented in the commit history

## Opting Out

If you need the unfiltered lists for legitimate purposes (academic research, historical fiction, etc.), use the raw data files in `data/` directly rather than the generated `lists/`.
