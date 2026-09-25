#!/usr/bin/env ruby
# Persist assets/images/{sifra}/* in matching article front matter.
# Run: ruby scripts/sync_article_images.rb

require "yaml"

root = File.expand_path("..", __dir__)
extensions = %w[.avif .gif .jpeg .jpg .png .webp]
updated = 0

Dir.glob(File.join(root, "assets/images/*")).sort.each do |directory|
  next unless File.directory?(directory)

  sifra = File.basename(directory)
  article = File.join(root, "_articles", "#{sifra}.md")
  next unless File.file?(article)

  images = Dir.children(directory).sort.select do |filename|
    File.file?(File.join(directory, filename)) && extensions.include?(File.extname(filename).downcase)
  end.map { |filename| "/assets/images/#{sifra}/#{filename}" }
  next if images.empty?

  source = File.read(article)
  parts = source.split(/^---\s*$\n?/, 3)
  raise "Missing front matter: #{article}" unless parts.length == 3 && parts[0].strip.empty?

  front_matter = YAML.safe_load(parts[1])
  next if front_matter["images"] == images

  front_matter["images"] = images
  File.write(article, "#{front_matter.to_yaml}---\n#{parts[2]}")
  updated += 1
end

puts "Updated images in #{updated} articles"
