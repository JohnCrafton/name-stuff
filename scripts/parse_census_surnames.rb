#!/usr/bin/env ruby
# frozen_string_literal: true

# Parse US Census 2010 surname data
# Outputs standardized format: name|frequency|tags

require 'csv'
require 'fileutils'

SOURCE_FILE = File.join(__dir__, '..', 'sources', 'census-2010-surnames', 'Names_2010Census.csv')
OUTPUT_DIR = File.join(__dir__, '..', 'data', 'en')

def normalize_frequency(prop100k)
  # Convert per-100k to 1-13 scale similar to given names
  # Top names are ~800/100k, rare ones are ~0.3/100k
  # Use log scale: 13 = 500+, 1 = <1
  return 1 if prop100k.nil? || prop100k <= 0

  log_val = Math.log10(prop100k + 1)
  # log10(1) = 0, log10(10) = 1, log10(100) = 2, log10(1000) = 3
  # Scale to 1-13
  scaled = (log_val * 4.5).round
  [[scaled, 1].max, 13].min
end

def title_case(name)
  # Convert SMITH to Smith, MCDONALD to McDonald
  name.downcase.gsub(/\b\w/) { |c| c.upcase }.tap do |result|
    # Handle Mc/Mac prefixes
    result.gsub!(/\bMc(\w)/) { "Mc#{$1.upcase}" }
    result.gsub!(/\bMac(\w)/) { "Mac#{$1.upcase}" }
    # Handle O' prefix
    result.gsub!(/\bO'(\w)/) { "O'#{$1.upcase}" }
  end
end

def main
  puts "Parsing #{SOURCE_FILE}..."

  FileUtils.mkdir_p(OUTPUT_DIR)

  entries = []

  CSV.foreach(SOURCE_FILE, headers: true) do |row|
    name = row['name']
    next if name.nil? || name.empty?

    prop100k = row['prop100k'].to_f
    freq = normalize_frequency(prop100k)

    entries << {
      name: title_case(name),
      freq: freq,
      tags: []
    }
  end

  puts "Parsed #{entries.length} surnames"

  # Sort alphabetically
  entries.sort_by! { |e| e[:name].downcase }

  # Write output
  filepath = File.join(OUTPUT_DIR, 'family.txt')
  File.open(filepath, 'w:UTF-8') do |f|
    f.puts "# name-stuff family names for culture: en"
    f.puts "# format: name|frequency|tags"
    f.puts "# frequency: 1-13 (higher = more common)"
    f.puts "# source: US Census Bureau 2010 (Public Domain)"
    f.puts "#"
    entries.each do |entry|
      tags = entry[:tags].join(',')
      f.puts "#{entry[:name]}|#{entry[:freq]}|#{tags}"
    end
  end

  puts "Wrote #{entries.length} surnames to #{filepath}"
  puts "Done!"
end

main if __FILE__ == $0
