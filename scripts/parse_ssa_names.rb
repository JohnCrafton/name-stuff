#!/usr/bin/env ruby
# frozen_string_literal: true

# Parse SSA Baby Names data and merge with existing en/given.txt
# Source: https://www.ssa.gov/oact/babynames/names.zip (CC0/Public Domain)
#
# This script:
# 1. Reads all year files (yob1880.txt - yob2024.txt)
# 2. Aggregates total counts and identifies peak decades
# 3. Merges with existing en/given.txt
# 4. Adds era tags (vintage, modern) based on peak usage
# 5. Updates frequency scores

require 'fileutils'

SOURCE_DIR = File.join(__dir__, '..', 'sources', 'ssa-baby-names')
DATA_FILE = File.join(__dir__, '..', 'data', 'en', 'given.txt')
OUTPUT_FILE = DATA_FILE # Overwrite in place

# Era definitions for tagging
ERAS = {
  'vintage' => (1880..1940),   # Peak usage 1880-1940
  'classic' => (1941..1979),   # Peak usage 1941-1979 (no tag, considered "normal")
  'modern' => (1980..2024)     # Peak usage 1980-present
}

# Minimum total count to include a name (filters out very rare names)
MIN_TOTAL_COUNT = 100

# Read existing data file
def read_existing_data(filepath)
  names = {}
  return names unless File.exist?(filepath)

  File.foreach(filepath, encoding: 'UTF-8') do |line|
    next if line.start_with?('#')
    next if line.strip.empty?

    parts = line.strip.split('|')
    next if parts.length < 3

    name = parts[0]
    gender = parts[1]
    freq = parts[2].to_i
    tags = parts[3]&.split(',')&.reject(&:empty?) || []

    names[name.downcase] = {
      name: name,
      gender: gender,
      freq: freq,
      tags: tags,
      from_existing: true
    }
  end

  names
end

# Parse all SSA year files
def parse_ssa_data(source_dir)
  names = Hash.new { |h, k| h[k] = { total: 0, by_year: {}, genders: Hash.new(0) } }

  Dir.glob(File.join(source_dir, 'yob*.txt')).sort.each do |filepath|
    year = File.basename(filepath, '.txt').sub('yob', '').to_i
    next if year < 1880

    File.foreach(filepath, encoding: 'UTF-8') do |line|
      parts = line.strip.split(',')
      next if parts.length < 3

      name = parts[0]
      gender = parts[1]
      count = parts[2].to_i

      key = name.downcase
      names[key][:name] ||= name  # Keep original casing from first occurrence
      names[key][:total] += count
      names[key][:by_year][year] ||= 0
      names[key][:by_year][year] += count
      names[key][:genders][gender] += count
    end
  end

  names
end

# Determine the peak decade for a name
def peak_decade(by_year)
  return nil if by_year.empty?

  # Sum by decade
  decades = Hash.new(0)
  by_year.each do |year, count|
    decade = (year / 10) * 10
    decades[decade] += count
  end

  # Find peak decade
  decades.max_by { |_, count| count }&.first
end

# Determine era tag based on peak usage
def era_tag(by_year)
  peak = peak_decade(by_year)
  return nil unless peak

  peak_year = peak + 5  # Use middle of decade

  ERAS.each do |tag, range|
    return tag if range.cover?(peak_year)
  end

  nil
end

# Determine gender from SSA data
def determine_gender(genders)
  male = genders['M'] || 0
  female = genders['F'] || 0
  total = male + female

  return 'U' if total == 0

  male_ratio = male.to_f / total

  if male_ratio > 0.95
    'M'
  elsif male_ratio > 0.75
    'M?'
  elsif male_ratio > 0.25
    'U'
  elsif male_ratio > 0.05
    'F?'
  else
    'F'
  end
end

# Convert total count to frequency score (1-13 scale)
def count_to_frequency(total)
  # Logarithmic scale based on SSA data distribution
  # Top names have millions, rare names have ~100
  case total
  when 0..100 then 1
  when 101..500 then 2
  when 501..1000 then 3
  when 1001..5000 then 4
  when 5001..10000 then 5
  when 10001..50000 then 6
  when 50001..100000 then 7
  when 100001..250000 then 8
  when 250001..500000 then 9
  when 500001..1000000 then 10
  when 1000001..2000000 then 11
  when 2000001..4000000 then 12
  else 13
  end
end

# Merge SSA data with existing data
def merge_data(existing, ssa_data)
  merged = {}

  # Start with existing data
  existing.each do |key, entry|
    merged[key] = entry.dup
  end

  # Process SSA data
  ssa_data.each do |key, ssa_entry|
    next if ssa_entry[:total] < MIN_TOTAL_COUNT

    ssa_gender = determine_gender(ssa_entry[:genders])
    ssa_freq = count_to_frequency(ssa_entry[:total])
    ssa_era = era_tag(ssa_entry[:by_year])

    if merged[key]
      # Update existing entry
      entry = merged[key]

      # Use higher frequency if SSA suggests it
      entry[:freq] = [entry[:freq], ssa_freq].max

      # Add era tag if not already present and not 'classic'
      if ssa_era && ssa_era != 'classic' && !entry[:tags].include?(ssa_era)
        entry[:tags] << ssa_era
      end

      entry[:ssa_total] = ssa_entry[:total]
    else
      # New entry from SSA
      tags = []
      tags << ssa_era if ssa_era && ssa_era != 'classic'

      merged[key] = {
        name: ssa_entry[:name],
        gender: ssa_gender,
        freq: ssa_freq,
        tags: tags,
        from_existing: false,
        ssa_total: ssa_entry[:total]
      }
    end
  end

  merged
end

# Write output file
def write_output(filepath, names)
  # Sort alphabetically by name
  sorted = names.values.sort_by { |n| n[:name].downcase }

  File.open(filepath, 'w:UTF-8') do |f|
    f.puts "# name-stuff given names for culture: en"
    f.puts "# format: name|gender|frequency|tags"
    f.puts "# gender: M=male, F=female, U=unisex, M?=mostly male, F?=mostly female"
    f.puts "# frequency: 1-13 (higher = more common)"
    f.puts "# sources: gender.c dictionary + US SSA Baby Names (CC0)"
    f.puts "#"

    sorted.each do |entry|
      tags = entry[:tags].uniq.sort.join(',')
      f.puts "#{entry[:name]}|#{entry[:gender]}|#{entry[:freq]}|#{tags}"
    end
  end

  sorted.length
end

def main
  puts "Reading existing data from #{DATA_FILE}..."
  existing = read_existing_data(DATA_FILE)
  puts "  Found #{existing.length} existing names"

  puts "Parsing SSA data from #{SOURCE_DIR}..."
  ssa_data = parse_ssa_data(SOURCE_DIR)
  puts "  Found #{ssa_data.length} unique names in SSA data"

  filtered_count = ssa_data.count { |_, v| v[:total] >= MIN_TOTAL_COUNT }
  puts "  #{filtered_count} names meet minimum count threshold (#{MIN_TOTAL_COUNT})"

  puts "Merging data..."
  merged = merge_data(existing, ssa_data)

  new_count = merged.count { |_, v| !v[:from_existing] }
  puts "  Adding #{new_count} new names from SSA"

  puts "Writing output to #{OUTPUT_FILE}..."
  total = write_output(OUTPUT_FILE, merged)
  puts "  Wrote #{total} total names"

  # Stats
  vintage_count = merged.count { |_, v| v[:tags].include?('vintage') }
  modern_count = merged.count { |_, v| v[:tags].include?('modern') }
  puts "\nEra tags added:"
  puts "  vintage: #{vintage_count}"
  puts "  modern: #{modern_count}"

  puts "\nDone!"
end

main if __FILE__ == $0
