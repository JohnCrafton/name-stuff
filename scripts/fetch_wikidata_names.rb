#!/usr/bin/env ruby
# frozen_string_literal: true

# Fetch mythological, biblical, and historical names from Wikidata
# Source: https://www.wikidata.org (CC0)
#
# This script:
# 1. Queries Wikidata SPARQL endpoint for various name categories
# 2. Tags matching names in culture files with appropriate tags
# 3. Reports on names found but not in current dataset

require 'net/http'
require 'uri'
require 'json'
require 'fileutils'

WIKIDATA_ENDPOINT = 'https://query.wikidata.org/sparql'
DATA_DIR = File.join(__dir__, '..', 'data')

# Wikidata Q-numbers for various categories
# Format: { tag => { label => Q-number } }
QUERIES = {
  'mythological' => {
    'Greek deity' => 'Q22989102',
    'Roman deity' => 'Q21070568',
    'Norse deity' => 'Q16513881',
    'Egyptian deity' => 'Q21070598',
    'Hindu deity' => 'Q14933824',
    'Celtic deity' => 'Q1475995',
    'Mesopotamian deity' => 'Q80071927',
    'Japanese deity' => 'Q25437922',
    'Chinese deity' => 'Q18576316',
    'Greek mythological figure' => 'Q22988604',
    'Greek mythological hero' => 'Q41573',
    'figure from Greek mythology' => 'Q22988604',
  },
  'biblical' => {
    'biblical figure' => 'Q20643955',
    'person in the Bible' => 'Q51070155',
    'character in the Hebrew Bible' => 'Q4184426',
  }
}

# Build SPARQL query for a given Q-number
def build_query(q_number, limit = 500)
  <<~SPARQL
    SELECT DISTINCT ?item ?itemLabel WHERE {
      ?item wdt:P31/wdt:P279* wd:#{q_number} .
      ?item rdfs:label ?itemLabel .
      FILTER(LANG(?itemLabel) = "en")
      FILTER(!CONTAINS(?itemLabel, " "))
      FILTER(STRLEN(?itemLabel) >= 2)
      FILTER(STRLEN(?itemLabel) <= 20)
    }
    LIMIT #{limit}
  SPARQL
end

# Execute SPARQL query against Wikidata
def execute_query(query)
  uri = URI(WIKIDATA_ENDPOINT)
  uri.query = URI.encode_www_form(query: query, format: 'json')

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.open_timeout = 30
  http.read_timeout = 60

  request = Net::HTTP::Get.new(uri)
  request['User-Agent'] = 'name-stuff/1.0 (https://github.com/JohnCrafton/name-stuff)'
  request['Accept'] = 'application/json'

  response = http.request(request)

  if response.code == '200'
    JSON.parse(response.body)
  else
    puts "  Warning: Query failed with code #{response.code}"
    nil
  end
rescue => e
  puts "  Warning: Query error: #{e.message}"
  nil
end

# Extract names from Wikidata response
def extract_names(response)
  return [] unless response && response['results'] && response['results']['bindings']

  response['results']['bindings'].map do |binding|
    label = binding['itemLabel']['value']
    # Clean up: capitalize first letter, skip if contains numbers or special chars
    next if label.match?(/[0-9\(\)\[\]\/]/)
    label.strip
  end.compact.uniq
end

# Fetch all names for a tag category
def fetch_names_for_tag(tag, categories)
  all_names = {}

  categories.each do |label, q_number|
    print "  Querying #{label} (#{q_number})... "
    query = build_query(q_number)
    response = execute_query(query)
    names = extract_names(response)
    puts "#{names.length} names"

    names.each do |name|
      key = name.downcase
      all_names[key] ||= { name: name, sources: [] }
      all_names[key][:sources] << label
    end

    # Be polite to the Wikidata servers
    sleep(1)
  end

  all_names
end

# Read existing data file
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

# Write data file
def write_data_file(filepath, entries, culture)
  sorted = entries.values.sort_by { |n| n[:name].downcase }

  File.open(filepath, 'w:UTF-8') do |f|
    f.puts "# name-stuff given names for culture: #{culture}"
    f.puts "# format: name|gender|frequency|tags"
    f.puts "# gender: M=male, F=female, U=unisex, M?=mostly male, F?=mostly female"
    f.puts "# frequency: 1-13 (higher = more common)"
    f.puts "# sources: gender.c dictionary + US SSA Baby Names (CC0)" if culture == 'en'
    f.puts "#"

    sorted.each do |entry|
      tags = entry[:tags].uniq.sort.join(',')
      f.puts "#{entry[:name]}|#{entry[:gender]}|#{entry[:freq]}|#{tags}"
    end
  end

  sorted.length
end

# Tag matching names across all cultures
def tag_names(wikidata_names, tag)
  total_tagged = 0

  Dir.glob(File.join(DATA_DIR, '*', 'given.txt')).sort.each do |filepath|
    culture = File.basename(File.dirname(filepath))
    entries = read_data_file(filepath)
    next if entries.empty?

    tagged_count = 0

    entries.each do |key, entry|
      if wikidata_names.key?(key) && !entry[:tags].include?(tag)
        entry[:tags] << tag
        tagged_count += 1
      end
    end

    if tagged_count > 0
      write_data_file(filepath, entries, culture)
      puts "  #{culture}: tagged #{tagged_count} names with '#{tag}'"
      total_tagged += tagged_count
    end
  end

  total_tagged
end

def main
  puts "Fetching names from Wikidata (CC0)..."
  puts "=" * 50

  all_wikidata_names = {}

  QUERIES.each do |tag, categories|
    puts "\nFetching '#{tag}' names..."
    names = fetch_names_for_tag(tag, categories)
    puts "  Total unique: #{names.length}"

    # Tag existing names
    puts "\nTagging existing names with '#{tag}'..."
    tagged = tag_names(names, tag)
    puts "  Total tagged: #{tagged}"

    # Collect for reporting
    names.each do |key, data|
      all_wikidata_names[key] ||= { name: data[:name], tags: [], sources: [] }
      all_wikidata_names[key][:tags] << tag
      all_wikidata_names[key][:sources].concat(data[:sources])
    end
  end

  # Report names not in any culture file
  puts "\n" + "=" * 50
  puts "Names from Wikidata not in current dataset:"

  existing_names = {}
  Dir.glob(File.join(DATA_DIR, '*', 'given.txt')).each do |filepath|
    read_data_file(filepath).each_key { |k| existing_names[k] = true }
  end

  not_found = all_wikidata_names.reject { |k, _| existing_names.key?(k) }
  puts "  #{not_found.length} names not in any culture file"

  # Sample some interesting ones
  puts "\nSample unmatched names (could be added manually):"
  not_found.to_a.sample(20).each do |key, data|
    puts "  #{data[:name]} (#{data[:tags].join(', ')} - #{data[:sources].first})"
  end

  puts "\nDone!"
end

main if __FILE__ == $0
