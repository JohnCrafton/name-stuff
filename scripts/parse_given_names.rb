#!/usr/bin/env ruby
# frozen_string_literal: true

# Parse nam_dict.txt and extract given names by culture
# Outputs standardized format: name|gender|tags

require 'fileutils'

SOURCE_FILE = File.join(__dir__, '..', 'sources', 'gender-c-original', 'nam_dict.txt')
OUTPUT_DIR = File.join(__dir__, '..', 'data')

# Country code mapping (position in source file -> ISO code)
# Positions are 0-indexed from column 30
COUNTRY_COLUMNS = {
  0 => 'gb',   # Great Britain
  1 => 'ie',   # Ireland
  2 => 'us',   # USA
  3 => 'it',   # Italy
  4 => 'mt',   # Malta
  5 => 'pt',   # Portugal
  6 => 'es',   # Spain
  7 => 'fr',   # France
  8 => 'be',   # Belgium
  9 => 'lu',   # Luxembourg
  10 => 'nl',  # Netherlands
  11 => 'ef',  # East Frisia (special region)
  12 => 'de',  # Germany
  13 => 'at',  # Austria
  14 => 'ch',  # Swiss
  15 => 'is',  # Iceland
  16 => 'dk',  # Denmark
  17 => 'no',  # Norway
  18 => 'se',  # Sweden
  19 => 'fi',  # Finland
  20 => 'ee',  # Estonia
  21 => 'lv',  # Latvia
  22 => 'lt',  # Lithuania
  23 => 'pl',  # Poland
  24 => 'cz',  # Czech Republic
  25 => 'sk',  # Slovakia
  26 => 'hu',  # Hungary
  27 => 'ro',  # Romania
  28 => 'bg',  # Bulgaria
  29 => 'ba',  # Bosnia and Herzegovina
  30 => 'hr',  # Croatia
  31 => 'xk',  # Kosovo
  32 => 'mk',  # Macedonia
  33 => 'me',  # Montenegro
  34 => 'rs',  # Serbia
  35 => 'si',  # Slovenia
  36 => 'al',  # Albania
  37 => 'gr',  # Greece
  38 => 'ru',  # Russia
  39 => 'by',  # Belarus
  40 => 'md',  # Moldova
  41 => 'ua',  # Ukraine
  42 => 'am',  # Armenia
  43 => 'az',  # Azerbaijan
  44 => 'ge',  # Georgia
  45 => 'kz',  # Kazakhstan/Uzbekistan/Central Asia
  46 => 'tr',  # Turkey
  47 => 'ar',  # Arabia/Persia
  48 => 'il',  # Israel
  49 => 'cn',  # China
  50 => 'in',  # India/Sri Lanka
  51 => 'jp',  # Japan
  52 => 'kr',  # Korea
  53 => 'vn',  # Vietnam
  54 => 'other'
}

# Culture groupings (which country codes merge into which culture)
CULTURE_GROUPS = {
  'en' => %w[gb ie us],
  'de' => %w[de at ch ef],
  'es' => %w[es],
  'fr' => %w[fr be lu],
  'it' => %w[it mt],
  'pt' => %w[pt],
  'nl' => %w[nl],
  'pl' => %w[pl],
  'ru' => %w[ru by md ua],
  'nordic' => %w[is dk no se fi],
  'baltic' => %w[ee lv lt],
  'slavic' => %w[cz sk hu ro bg ba hr xk mk me rs si],
  'greek' => %w[gr],
  'albanian' => %w[al],
  'caucasus' => %w[am az ge],
  'turkic' => %w[tr kz],
  'arab' => %w[ar],
  'hebrew' => %w[il],
  'chinese' => %w[cn],
  'indian' => %w[in],
  'japanese' => %w[jp],
  'korean' => %w[kr],
  'vietnamese' => %w[vn]
}

# Reverse mapping: country code -> cultures it belongs to
COUNTRY_TO_CULTURES = {}
CULTURE_GROUPS.each do |culture, countries|
  countries.each do |cc|
    COUNTRY_TO_CULTURES[cc] ||= []
    COUNTRY_TO_CULTURES[cc] << culture
  end
end

# Gender code normalization
GENDER_MAP = {
  'M' => 'M',
  'F' => 'F',
  '?' => 'U',
  '?M' => 'M?',  # mostly male
  '?F' => 'F?',  # mostly female
  '1M' => 'M',   # male if first part
  '1F' => 'F'    # female if first part
}

# Unicode escape sequences from the source file
UNICODE_MAP = {
  '<A/>' => 'Ā', '<a/>' => 'ā',
  '<A,>' => 'Ą', '<a,>' => 'ą',
  '<C´>' => 'Ć', '<c´>' => 'ć',
  '<C^>' => 'Č', '<c^>' => 'č',
  '<CH>' => 'Č', '<ch>' => 'č',
  '<d´>' => 'ď',
  '<DJ>' => 'Đ', '<dj>' => 'đ',
  '<E/>' => 'Ē', '<e/>' => 'ē',
  '<E´>' => 'Ė', '<e´>' => 'ė',
  '<E,>' => 'Ę', '<e,>' => 'ę',
  '<G^>' => 'Ğ', '<g^>' => 'ğ',
  '<G,>' => 'Ģ', '<g´>' => 'ģ',
  '<I/>' => 'Ī', '<i/>' => 'ī',
  '<I´>' => 'İ', '<i>' => 'ı',
  '<IJ>' => 'Ĳ', '<ij>' => 'ĳ',
  '<K,>' => 'Ķ', '<k,>' => 'ķ',
  '<L,>' => 'Ļ', '<l,>' => 'ļ',
  '<L´>' => 'Ľ', '<l´>' => 'ľ',
  '<L/>' => 'Ł', '<l/>' => 'ł',
  '<N,>' => 'Ņ', '<n,>' => 'ņ',
  '<N^>' => 'Ň', '<n^>' => 'ň',
  '<OE>' => 'Œ', '<oe>' => 'œ',
  '<R^>' => 'Ř', '<r^>' => 'ř',
  '<S,>' => 'Ş', '<s,>' => 'ş',
  '<S^>' => 'Š', '<s^>' => 'š',
  '<SCH>' => 'Š', '<sch>' => 'š',
  '<SH>' => 'Š', '<sh>' => 'š',
  '<T,>' => 'Ţ', '<t,>' => 'ţ',
  '<t´>' => 'ť',
  '<U/>' => 'Ū', '<u/>' => 'ū',
  '<U´>' => 'Ů', '<u´>' => 'ů',
  '<U,>' => 'Ų', '<u,>' => 'ų',
  '<Z´>' => 'Ź', '<z´>' => 'ź',
  '<Z^>' => 'Ž', '<z^>' => 'ž',
  '<ß>' => 'ẞ'
}

def convert_unicode(name)
  # First encode to UTF-8
  result = name.encode('UTF-8')
  UNICODE_MAP.each do |escape, char|
    result.gsub!(escape, char)
  end
  # Handle + in names (Arabic, Chinese, Korean) -> keep as-is for now
  result
end

def parse_gender(code)
  GENDER_MAP[code.strip] || 'U'
end

def parse_frequency(char)
  return 0 if char.nil? || char == ' ' || char == '$'
  char.to_i(16)
end

def parse_line(line)
  return nil if line.start_with?('#')
  return nil if line.strip.empty?
  return nil if line[29] == '+' # Skip umlaut duplicate entries

  # Parse gender (columns 0-1)
  gender_code = line[0..1].strip
  return nil if gender_code == '=' # Skip equivalent name entries for now

  # Parse name (columns 3-28)
  name = line[3..28].strip
  return nil if name.empty?

  # Convert unicode escapes
  name = convert_unicode(name)

  # Parse country frequencies (columns 30+)
  freq_str = line[30..-1] || ''
  frequencies = {}

  COUNTRY_COLUMNS.each do |pos, country_code|
    char = freq_str[pos]
    freq = parse_frequency(char)
    frequencies[country_code] = freq if freq > 0
  end

  {
    name: name,
    gender: parse_gender(gender_code),
    frequencies: frequencies
  }
end

def aggregate_by_culture(entries)
  cultures = Hash.new { |h, k| h[k] = {} }

  entries.each do |entry|
    entry[:frequencies].each do |country_code, freq|
      next if country_code == 'other'

      target_cultures = COUNTRY_TO_CULTURES[country_code] || []
      target_cultures.each do |culture|
        key = entry[:name]
        existing = cultures[culture][key]

        if existing
          # Keep higher frequency, combine genders if different
          existing[:freq] = [existing[:freq], freq].max
          if existing[:gender] != entry[:gender]
            existing[:gender] = 'U' # Mark as unisex if appears with different genders
          end
        else
          cultures[culture][key] = {
            name: entry[:name],
            gender: entry[:gender],
            freq: freq,
            tags: []
          }
        end
      end
    end
  end

  cultures
end

def write_culture_file(culture, names, output_dir)
  culture_dir = File.join(output_dir, culture)
  FileUtils.mkdir_p(culture_dir)

  # Sort by name alphabetically
  sorted = names.values.sort_by { |n| n[:name].downcase }

  filepath = File.join(culture_dir, 'given.txt')
  File.open(filepath, 'w:UTF-8') do |f|
    f.puts "# name-stuff given names for culture: #{culture}"
    f.puts "# format: name|gender|frequency|tags"
    f.puts "# gender: M=male, F=female, U=unisex, M?=mostly male, F?=mostly female"
    f.puts "# frequency: 1-13 (higher = more common)"
    f.puts "#"
    sorted.each do |entry|
      tags = entry[:tags].join(',')
      f.puts "#{entry[:name]}|#{entry[:gender]}|#{entry[:freq]}|#{tags}"
    end
  end

  puts "Wrote #{sorted.length} names to #{filepath}"
end

def main
  puts "Parsing #{SOURCE_FILE}..."

  entries = []
  File.foreach(SOURCE_FILE, encoding: 'ISO-8859-1') do |line|
    entry = parse_line(line)
    entries << entry if entry
  end

  puts "Parsed #{entries.length} name entries"

  puts "Aggregating by culture..."
  cultures = aggregate_by_culture(entries)

  puts "Writing culture files..."
  cultures.each do |culture, names|
    write_culture_file(culture, names, OUTPUT_DIR)
  end

  puts "Done!"
end

main if __FILE__ == $0
