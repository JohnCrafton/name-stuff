#!/usr/bin/env ruby
# frozen_string_literal: true

# Parse sigpwned popular-names-by-country surname data
# Outputs standardized format: name|frequency|tags

require 'csv'
require 'fileutils'

SOURCE_FILE = File.join(__dir__, '..', 'sources', 'popular-names-by-country', 'common-surnames-by-country.csv')
OUTPUT_DIR = File.join(__dir__, '..', 'data')

# Map ISO country codes to our culture codes
COUNTRY_TO_CULTURE = {
  'AM' => 'caucasus',   # Armenia
  'AZ' => 'caucasus',   # Azerbaijan
  'GE' => 'caucasus',   # Georgia
  'AT' => 'de',         # Austria
  'DE' => 'de',         # Germany
  'CH' => 'de',         # Switzerland
  'BE' => 'fr',         # Belgium (French)
  'FR' => 'fr',         # France
  'LU' => 'fr',         # Luxembourg
  'GB' => 'en',         # Great Britain
  'IE' => 'en',         # Ireland
  'US' => 'en',         # USA
  'AU' => 'en',         # Australia
  'CA' => 'en',         # Canada
  'NZ' => 'en',         # New Zealand
  'ES' => 'es',         # Spain
  'MX' => 'es',         # Mexico
  'AR' => 'es',         # Argentina
  'CO' => 'es',         # Colombia
  'IT' => 'it',         # Italy
  'PT' => 'pt',         # Portugal
  'BR' => 'pt',         # Brazil
  'NL' => 'nl',         # Netherlands
  'PL' => 'pl',         # Poland
  'RU' => 'ru',         # Russia
  'UA' => 'ru',         # Ukraine
  'BY' => 'ru',         # Belarus
  'DK' => 'nordic',     # Denmark
  'FI' => 'nordic',     # Finland
  'IS' => 'nordic',     # Iceland
  'NO' => 'nordic',     # Norway
  'SE' => 'nordic',     # Sweden
  'EE' => 'baltic',     # Estonia
  'LT' => 'baltic',     # Lithuania
  'LV' => 'baltic',     # Latvia
  'CZ' => 'slavic',     # Czech Republic
  'SK' => 'slavic',     # Slovakia
  'HU' => 'slavic',     # Hungary
  'RO' => 'slavic',     # Romania
  'BG' => 'slavic',     # Bulgaria
  'HR' => 'slavic',     # Croatia
  'RS' => 'slavic',     # Serbia
  'SI' => 'slavic',     # Slovenia
  'BA' => 'slavic',     # Bosnia
  'MK' => 'slavic',     # Macedonia
  'ME' => 'slavic',     # Montenegro
  'XK' => 'slavic',     # Kosovo
  'GR' => 'greek',      # Greece
  'CY' => 'greek',      # Cyprus
  'AL' => 'albanian',   # Albania
  'TR' => 'turkic',     # Turkey
  'KZ' => 'turkic',     # Kazakhstan
  'IL' => 'hebrew',     # Israel
  'SA' => 'arab',       # Saudi Arabia
  'AE' => 'arab',       # UAE
  'EG' => 'arab',       # Egypt
  'IR' => 'arab',       # Iran
  'IQ' => 'arab',       # Iraq
  'SY' => 'arab',       # Syria
  'JO' => 'arab',       # Jordan
  'LB' => 'arab',       # Lebanon
  'CN' => 'chinese',    # China
  'TW' => 'chinese',    # Taiwan
  'HK' => 'chinese',    # Hong Kong
  'SG' => 'chinese',    # Singapore
  'IN' => 'indian',     # India
  'PK' => 'indian',     # Pakistan
  'BD' => 'indian',     # Bangladesh
  'LK' => 'indian',     # Sri Lanka
  'NP' => 'indian',     # Nepal
  'JP' => 'japanese',   # Japan
  'KR' => 'korean',     # South Korea
  'KP' => 'korean',     # North Korea
  'VN' => 'vietnamese', # Vietnam
  'PH' => 'other',      # Philippines
  'ID' => 'other',      # Indonesia
  'MY' => 'other',      # Malaysia
  'TH' => 'other'       # Thailand
}

def rank_to_frequency(rank)
  # Convert rank (1-N) to frequency (1-13)
  # Rank 1 = freq 13, lower ranks get lower frequencies
  return 13 if rank <= 3
  return 12 if rank <= 5
  return 11 if rank <= 10
  return 10 if rank <= 15
  return 9 if rank <= 20
  return 8 if rank <= 30
  return 7 if rank <= 40
  return 6 if rank <= 50
  return 5 if rank <= 75
  return 4 if rank <= 100
  return 3 if rank <= 150
  return 2 if rank <= 200
  1
end

def main
  puts "Parsing #{SOURCE_FILE}..."

  # Group by culture
  cultures = Hash.new { |h, k| h[k] = {} }

  CSV.foreach(SOURCE_FILE, headers: true, encoding: 'bom|utf-8') do |row|
    country = row['Country']
    culture = COUNTRY_TO_CULTURE[country]
    next unless culture
    next if culture == 'en' # Skip en, we have better Census data

    rank = row['Rank'].to_i
    # Prefer romanized name, fall back to localized
    name = row['Romanized Name']
    name = row['Localized Name'] if name.nil? || name.strip.empty?
    next if name.nil? || name.strip.empty?

    name = name.strip
    freq = rank_to_frequency(rank)

    # Use romanized name as key, keep both versions
    key = name.downcase
    existing = cultures[culture][key]

    if existing
      existing[:freq] = [existing[:freq], freq].max
    else
      cultures[culture][key] = {
        name: name,
        freq: freq,
        tags: []
      }
    end
  end

  puts "Writing culture files..."

  cultures.each do |culture, names|
    next if names.empty?

    culture_dir = File.join(OUTPUT_DIR, culture)
    FileUtils.mkdir_p(culture_dir)

    # Sort alphabetically
    sorted = names.values.sort_by { |n| n[:name].downcase }

    filepath = File.join(culture_dir, 'family.txt')
    File.open(filepath, 'w:UTF-8') do |f|
      f.puts "# name-stuff family names for culture: #{culture}"
      f.puts "# format: name|frequency|tags"
      f.puts "# frequency: 1-13 (higher = more common)"
      f.puts "# source: popular-names-by-country-dataset (CC0)"
      f.puts "#"
      sorted.each do |entry|
        tags = entry[:tags].join(',')
        f.puts "#{entry[:name]}|#{entry[:freq]}|#{tags}"
      end
    end

    puts "Wrote #{sorted.length} surnames to #{filepath}"
  end

  puts "Done!"
end

main if __FILE__ == $0
