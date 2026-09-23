#!/usr/bin/env ruby
# Persist legacy /{category}/{sku}-{title}/ URLs in article front matter.
# Run: bundle exec ruby scripts/sync_article_redirects.rb

require "yaml"

root = File.expand_path("..", __dir__)
latin_map = { "č" => "c", "ć" => "c", "š" => "s", "ž" => "z", "đ" => "dj" }
updated = 0

Dir.glob(File.join(root, "_articles", "*.md")).sort.each do |path|
  source = File.read(path)
  parts = source.split(/^---\s*$\n?/, 3)
  raise "Missing front matter: #{path}" unless parts.length == 3 && parts[0].strip.empty?

  data = YAML.safe_load(parts[1])
  %w[category sku title].each do |key|
    raise "Missing #{key}: #{path}" if data[key].to_s.empty?
  end

  # Match the Serbian Latin title slugs used by the image importer.
  slug = data["title"].downcase
  latin_map.each { |letter, replacement| slug.gsub!(letter, replacement) }
  slug = slug.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
  raise "Empty title slug: #{path}" if slug.empty?

  redirect = "/#{data['category']}/#{data['sku']}-#{slug}/"
  redirects = (Array(data["redirect_from"]) + [redirect]).uniq
  next if data["redirect_from"] == redirects

  data["redirect_from"] = redirects
  File.write(path, "#{data.to_yaml}---\n#{parts[2]}")
  updated += 1
end

puts "Updated redirects in #{updated} articles"
