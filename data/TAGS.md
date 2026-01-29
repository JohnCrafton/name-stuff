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
- `biblical` - Names from religious texts
- `mythological` - Names from mythology (Greek, Norse, etc.)
- `historical` - Names of notable historical figures
- `literary` - Names from literature, film, or other media

### Usage Tags
- `archaic` - Names no longer in common use
- `modern` - Names that emerged recently
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
