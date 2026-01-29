#!/usr/bin/env ruby
# frozen_string_literal: true

# Generate size-tiered lists from full data
# Usage: ruby generate_lists.rb [culture] [--raw] [--ascii]
#
# Tiers:
#   sm  = ~100 most popular names
#   lg  = ~1/3 of names (sampled by frequency)
#   xl  = full list
#
# Options:
#   --raw    Output names only (no metadata)
#   --ascii  Strip non-ASCII characters

require 'fileutils'
require 'set'

DATA_DIR = File.join(__dir__, '..', 'data')
LISTS_DIR = File.join(__dir__, '..', 'lists')
SKIPS_FILE = File.join(__dir__, '..', 'skips', 'skips.txt')

SM_SIZE = 100
LG_RATIO = 0.33

def load_skips
  skips = Set.new
  return skips unless File.exist?(SKIPS_FILE)

  File.foreach(SKIPS_FILE, encoding: 'UTF-8') do |line|
    line = line.strip
    next if line.empty? || line.start_with?('#')
    name = line.split('|').first
    skips.add(name.downcase) if name
  end

  skips
end

SKIPS = load_skips

def load_names(filepath)
  names = []
  return names unless File.exist?(filepath)

  File.foreach(filepath, encoding: 'UTF-8') do |line|
    line = line.strip
    next if line.empty? || line.start_with?('#')

    parts = line.split('|')
    names << {
      name: parts[0],
      gender: parts[1],   # May be nil for surnames
      freq: parts[1]&.match?(/^\d+$/) ? parts[1].to_i : (parts[2]&.to_i || 1),
      tags: parts[-1] || ''
    }

    # Re-parse if it's a surname (name|freq|tags format)
    if parts.length == 3 && parts[1].match?(/^\d+$/)
      names[-1] = {
        name: parts[0],
        gender: nil,
        freq: parts[1].to_i,
        tags: parts[2] || ''
      }
    end
  end

  names
end

def ascii_safe?(name)
  name.ascii_only?
end

def to_ascii(name)
  # Common transliterations
  name.tr(
    'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ' \
    'ĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħĨĩĪīĬĭĮįİıĲĳĴĵĶķĸĹĺĻļĽľĿŀŁł' \
    'ŃńŅņŇňŉŊŋŌōŎŏŐőŒœŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽž',
    'AAAAAAACEEEEIIIIDNOOOOOOUUUUYTsaaaaaaaceeeeiiiidnoooooouuuuyty' \
    'AaAaAaCcCcCcCcDdDdEeEeEeEeEeGgGgGgGgHhHhIiIiIiIiIiIJijJjKkkLlLlLlLlLl' \
    'NnNnNnnNnOoOoOoOEoeRrRrRrSsSsSsSsTtTtTtUuUuUuUuUuUuWwYyYZzZzZz'
  )
end

def filter_ascii(names, ascii_only)
  return names unless ascii_only

  names.map do |n|
    n = n.dup
    n[:name] = to_ascii(n[:name])
    n
  end.select { |n| ascii_safe?(n[:name]) }
end

def filter_skips(names)
  names.reject { |n| SKIPS.include?(n[:name].downcase) }
end

def generate_sm(names)
  # Top ~100 by frequency
  sorted = names.sort_by { |n| [-n[:freq], n[:name].downcase] }
  sorted.first(SM_SIZE)
end

def generate_lg(names)
  # ~1/3 of names, weighted by frequency
  sorted = names.sort_by { |n| [-n[:freq], n[:name].downcase] }
  target_size = (names.length * LG_RATIO).ceil
  target_size = [target_size, SM_SIZE].max  # At least sm size
  sorted.first(target_size)
end

def generate_xl(names)
  # Full list, sorted alphabetically
  names.sort_by { |n| n[:name].downcase }
end

def format_output(names, raw_mode, name_type)
  lines = []

  unless raw_mode
    lines << "# name-stuff #{name_type} names"
    if name_type == 'given'
      lines << "# format: name|gender|frequency|tags"
    else
      lines << "# format: name|frequency|tags"
    end
    lines << "#"
  end

  names.each do |n|
    if raw_mode
      lines << n[:name]
    else
      if n[:gender]
        lines << "#{n[:name]}|#{n[:gender]}|#{n[:freq]}|#{n[:tags]}"
      else
        lines << "#{n[:name]}|#{n[:freq]}|#{n[:tags]}"
      end
    end
  end

  lines.join("\n") + "\n"
end

def write_list(culture, name_type, tier, names, raw_mode, ascii_only)
  suffix = ''
  suffix += '_raw' if raw_mode
  suffix += '_ascii' if ascii_only

  culture_dir = File.join(LISTS_DIR, culture)
  FileUtils.mkdir_p(culture_dir)

  filename = "#{name_type}_#{tier}#{suffix}.txt"
  filepath = File.join(culture_dir, filename)

  content = format_output(names, raw_mode, name_type)
  File.write(filepath, content, encoding: 'UTF-8')

  puts "  #{filename}: #{names.length} names"
end

def process_culture(culture, raw_mode, ascii_only)
  puts "Processing #{culture}..."

  culture_data_dir = File.join(DATA_DIR, culture)
  return unless Dir.exist?(culture_data_dir)

  # Process given names
  given_path = File.join(culture_data_dir, 'given.txt')
  if File.exist?(given_path)
    given_names = load_names(given_path)
    given_names = filter_skips(given_names)
    given_names = filter_ascii(given_names, ascii_only)

    if given_names.any?
      write_list(culture, 'given', 'sm', generate_sm(given_names), raw_mode, ascii_only)
      write_list(culture, 'given', 'lg', generate_lg(given_names), raw_mode, ascii_only)
      write_list(culture, 'given', 'xl', generate_xl(given_names), raw_mode, ascii_only)
    end
  end

  # Process family names
  family_path = File.join(culture_data_dir, 'family.txt')
  if File.exist?(family_path)
    family_names = load_names(family_path)
    family_names = filter_skips(family_names)
    family_names = filter_ascii(family_names, ascii_only)

    if family_names.any?
      write_list(culture, 'family', 'sm', generate_sm(family_names), raw_mode, ascii_only)
      write_list(culture, 'family', 'lg', generate_lg(family_names), raw_mode, ascii_only)
      write_list(culture, 'family', 'xl', generate_xl(family_names), raw_mode, ascii_only)
    end
  end
end

def main
  cultures = ARGV.reject { |a| a.start_with?('--') }
  raw_mode = ARGV.include?('--raw')
  ascii_only = ARGV.include?('--ascii')

  # If no cultures specified, process all
  if cultures.empty?
    cultures = Dir.children(DATA_DIR).select do |f|
      File.directory?(File.join(DATA_DIR, f))
    end
  end

  puts "Generating lists..."
  puts "  Raw mode: #{raw_mode}"
  puts "  ASCII only: #{ascii_only}"
  puts "  Skips loaded: #{SKIPS.size}"
  puts ""

  cultures.sort.each do |culture|
    process_culture(culture, raw_mode, ascii_only)
  end

  puts ""
  puts "Done!"
end

main if __FILE__ == $0
