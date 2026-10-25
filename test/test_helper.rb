# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require "date"

ROOT = File.expand_path("..", __dir__)
SITE = File.join(ROOT, "_site")

module ContentHelpers
  CONTENT_DIRS = %w[_posts _coding_notes _definitions _drafts].freeze

  def content_files
    CONTENT_DIRS.flat_map { |dir| Dir.glob(File.join(ROOT, dir, "**", "*.{md,html}")) }
  end

  def front_matter(path)
    text = File.read(path)
    match = text.match(/\A---[ \t]*\n(.*?)^---[ \t]*$/m)
    return nil unless match

    YAML.safe_load(match[1], permitted_classes: [Date, Time]) || {}
  rescue Psych::SyntaxError => e
    flunk "#{relative(path)} has invalid YAML front matter: #{e.message}"
  end

  def relative(path)
    path.delete_prefix("#{ROOT}/")
  end
end
