#!/usr/bin/env ruby
# Syncs _data/stock.yml into _articles/{sku}.md pages.
# Run to create/update/remove pages whenever collection data changes.

require "yaml"
require "fileutils"

STOCK_FILE      = File.expand_path("../_data/stock.yml", __dir__)
REPO_DIR        = File.expand_path("..", __dir__)
ARTICLES_DIR    = File.join(REPO_DIR, "_articles")

LATIN_MAP = {
  "č" => "c", "ć" => "c", "š" => "s", "ž" => "z", "đ" => "dj",
  "Č" => "c", "Ć" => "c", "Š" => "s", "Ž" => "z", "Đ" => "dj",
}.freeze

def slug(str)
  s = str.dup
  LATIN_MAP.each { |k, v| s.gsub!(k, v) }
  s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
end

def permalink(sku, title)
  "/#{sku}/#{slug title}"
end

def out_of_stock_at_both_locations?(item)
  item.fetch("srbobran", 0).to_i == 0 && item.fetch("futog", 0).to_i == 0
end

def existing_front_matter_and_body(path)
  return [{}, ""] unless File.exist?(path)

  source = File.read(path)
  parts = source.split(/^---\s*$\n?/, 3)
  return [{}, source] unless parts.length == 3 && parts[0].strip.empty?

  parsed = YAML.safe_load(parts[1])
  [parsed.is_a?(Hash) ? parsed : {}, parts[2]]
rescue Psych::Exception
  [{}, source]
end

def page_content(sku, item, path)
  existing_front_matter, body = existing_front_matter_and_body(path)
  front_matter = {
    "layout" => "article",
  }.merge(existing_front_matter).merge(
    "title"      => item["title"].to_s,
    "category"   => item["category"].to_s,
    "permalink" => permalink(sku, item["title"]),
    "sku"        => sku
  )

  if existing_front_matter["permalink"] != front_matter["permalink"]
    front_matter["redirect_from"] ||= []
    front_matter["redirect_from"].append existing_front_matter["permalink"]
  end

  "#{front_matter.to_yaml}---\n#{body}"
end

# Collect all pages that should exist after this run
desired_files = {}

items = YAML.safe_load(File.read(STOCK_FILE))
if items.is_a?(Hash)
  items.each do |sku, item|
    next unless item.is_a?(Hash)
    next if out_of_stock_at_both_locations?(item)

    file_path = File.join(ARTICLES_DIR, "#{sku}.md")
    desired_files[file_path] = page_content(sku, item, file_path)
  end
end

# Only remove stale generated files from _articles. Existing collection pages are
# left untouched until they are deliberately moved to _articles.
existing_files = Dir.glob(File.join(ARTICLES_DIR, "*.md"))

# Create or update pages
created = updated = 0
desired_files.each do |path, content|
  FileUtils.mkdir_p(File.dirname(path))
  if File.exist?(path)
    if File.read(path) != content
      File.write(path, content)
      updated += 1
    end
  else
    File.write(path, content)
    created += 1
  end
end

# Remove pages that no longer correspond to any item
removed = 0
existing_files.each do |path|
  unless desired_files.key?(path)
    File.delete(path)
    removed += 1
  end
end

puts "Done: #{created} created, #{updated} updated, #{removed} removed"
