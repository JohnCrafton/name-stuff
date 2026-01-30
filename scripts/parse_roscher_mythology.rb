#!/usr/bin/env ruby
# frozen_string_literal: true

# Parse Roscher's Lexicon of Mythology Index and tag matching names
# Source: https://zenodo.org/records/11113695 (CC0)
#
# This script:
# 1. Reads Roscher's Lexicon Index CSV files
# 2. Extracts mythological names (deities, characters, nymphs, etc.)
# 3. Tags matching names in all culture given.txt files with 'mythological'

require 'csv'
require 'fileutils'

SOURCE_DIR = File.join(__dir__, '..', 'sources', 'roscher-lexicon')
DATA_DIR = File.join(__dir__, '..', 'data')

# Subject types that represent named entities (not places, objects, concepts)
ENTITY_TYPES = %w[
  deity
  character
  nymph
  collective_deity
  centaur
  satyr
  collective_character
  creature
  hybrid
  collective_creature
  serpent
].freeze

# Parse Roscher CSV files and extract mythological names
def parse_roscher_data(source_dir)
  names = {}

  %w[RLM_Index_tab_A.csv RLM_Index_tab_B.csv].each do |filename|
    filepath = File.join(source_dir, filename)
    next unless File.exist?(filepath)

    CSV.foreach(filepath, col_sep: "\t", headers: true, encoding: 'UTF-8') do |row|
      headword = row['headword']
      subject_type = row['subject_type']

      next if headword.nil? || headword.empty?
      next unless ENTITY_TYPES.include?(subject_type)

      # Clean the name: remove numeric suffixes like " 1", " 2"
      clean_name = headword.sub(/\s+\d+$/, '').strip

      # Skip very short names or names with special characters
      next if clean_name.length < 2
      next if clean_name.include?('(') || clean_name.include?(')')

      # Normalize for matching (lowercase)
      key = clean_name.downcase

      names[key] ||= {
        name: clean_name,
        types: []
      }
      names[key][:types] << subject_type unless names[key][:types].include?(subject_type)
    end
  end

  names
end

# Read a data file and return entries
def read_data_file(filepath)
  entries = {}
  return entries unless File.exist?(filepath)

  File.foreach(filepath, encoding: 'UTF-8') do |line|
    next if line.start_with?('#')
    next if line.strip.empty?

    parts = line.strip.split('|')
    next if parts.length < 3

    name = parts[0]
    gender = parts[1]
    freq = parts[2].to_i
    tags = parts[3]&.split(',')&.reject(&:empty?) || []

    key = name.downcase
    entries[key] = {
      name: name,
      gender: gender,
      freq: freq,
      tags: tags
    }
  end

  entries
end

# Write a data file
def write_data_file(filepath, entries, culture)
  sorted = entries.values.sort_by { |n| n[:name].downcase }

  File.open(filepath, 'w:UTF-8') do |f|
    f.puts "# name-stuff given names for culture: #{culture}"
    f.puts "# format: name|gender|frequency|tags"
    f.puts "# gender: M=male, F=female, U=unisex, M?=mostly male, F?=mostly female"
    f.puts "# frequency: 1-13 (higher = more common)"

    # Add source note for en culture (which has SSA data)
    if culture == 'en'
      f.puts "# sources: gender.c dictionary + US SSA Baby Names (CC0)"
    end

    f.puts "#"

    sorted.each do |entry|
      tags = entry[:tags].uniq.sort.join(',')
      f.puts "#{entry[:name]}|#{entry[:gender]}|#{entry[:freq]}|#{tags}"
    end
  end

  sorted.length
end

# Tag matching names in a culture file
def tag_culture_file(culture, filepath, mythology_names)
  entries = read_data_file(filepath)
  return 0 if entries.empty?

  tagged_count = 0

  entries.each do |key, entry|
    if mythology_names.key?(key) && !entry[:tags].include?('mythological')
      entry[:tags] << 'mythological'
      tagged_count += 1
    end
  end

  if tagged_count > 0
    write_data_file(filepath, entries, culture)
  end

  tagged_count
end

def main
  puts "Parsing Roscher's Lexicon data from #{SOURCE_DIR}..."
  mythology_names = parse_roscher_data(SOURCE_DIR)
  puts "  Found #{mythology_names.length} unique mythological names"

  # Show breakdown by type
  type_counts = Hash.new(0)
  mythology_names.each do |_, data|
    data[:types].each { |t| type_counts[t] += 1 }
  end
  puts "  Types: #{type_counts.sort_by { |_, v| -v }.map { |k, v| "#{k}=#{v}" }.join(', ')}"

  puts "\nTagging names in culture files..."
  total_tagged = 0

  Dir.glob(File.join(DATA_DIR, '*', 'given.txt')).sort.each do |filepath|
    culture = File.basename(File.dirname(filepath))
    tagged = tag_culture_file(culture, filepath, mythology_names)

    if tagged > 0
      puts "  #{culture}: tagged #{tagged} names"
      total_tagged += tagged
    end
  end

  puts "\nTotal names tagged with 'mythological': #{total_tagged}"

  # Show some example matches
  puts "\nExample mythological names found:"
  sample_keys = mythology_names.keys.sample(10)
  sample_keys.each do |key|
    data = mythology_names[key]
    puts "  #{data[:name]} (#{data[:types].join(', ')})"
  end

  puts "\nDone!"
end

main if __FILE__ == $0
