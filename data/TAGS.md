# Name Tags Reference

Tags can be added to names in the data files to provide additional metadata for downstream consumers.

## Format

In data files, tags appear in the last field, comma-separated:

```
Hermione|F|3|literary,mythological
Atticus|M|2|literary
Thor|M|4|mythological,historical
```

## Available Tags

### Origin Tags
- `biblical` - Names from the Bible (e.g., Aaron, Abigail, Adam, Ruth, Noah)
- `mythological` - Names from mythology (Greek, Roman, Norse, Egyptian, Celtic, etc.)
- `historical` - Names of notable historical figures
- `literary` - Names from literature, film, or other media

### Era Tags
- `vintage` - Names that peaked in popularity 1880-1940 (e.g., Mildred, Edna, Clarence)
- `modern` - Names that peaked in popularity 1980-present (e.g., Liam, Olivia, Madison)
- (no tag) - "Classic" names with steady popularity across eras (e.g., James, William, Elizabeth)

### Usage Tags
- `archaic` - Names no longer in common use
- `formal` - Full/formal versions of names
- `diminutive` - Nicknames or shortened forms

### Special Tags
- `romanized` - Transliterated from non-Latin script
- `variant` - Spelling variant of another name

## Adding Tags

To add tags to names:

1. Edit the relevant file in `data/{culture}/given.txt` or `family.txt`
2. Add tags to the last field (comma-separated, no spaces)
3. Run `ruby scripts/generate_lists.rb` to regenerate lists
4. Submit a pull request with your additions

Tags are preserved through the generation process and appear in non-raw output formats.
