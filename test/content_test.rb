# frozen_string_literal: true

require "test_helper"

# Checks the Markdown/HTML sources before Jekyll ever sees them.
class ContentTest < Minitest::Test
  include ContentHelpers

  LAYOUTS = Dir.glob(File.join(ROOT, "_layouts", "*.html")).map { |f| File.basename(f, ".html") }

  def test_every_content_file_has_valid_front_matter
    content_files.each do |path|
      data = front_matter(path)
      refute_nil data, "#{relative(path)} is missing a --- front matter block"
      assert_kind_of Hash, data, "#{relative(path)} front matter must be key: value pairs"
    end
  end

  def test_layouts_exist
    content_files.each do |path|
      layout = front_matter(path)&.fetch("layout", nil)
      next if layout.nil?

      assert_includes LAYOUTS, layout, "#{relative(path)} uses unknown layout '#{layout}'"
    end
  end

  def test_tags_are_a_list_under_the_tags_key
    content_files.each do |path|
      data = front_matter(path) || {}
      %w[tag keys].each do |wrong|
        refute data.key?(wrong), "#{relative(path)} uses '#{wrong}:' — use 'tags:' instead"
      end
      next unless data.key?("tags")

      assert_kind_of Array, data["tags"], "#{relative(path)} tags should be a list, e.g. tags: [\"a\", \"b\"]"
    end
  end

  # Jekyll silently skips posts whose filename isn't YYYY-MM-DD-slug.
  def test_post_filenames_are_dated
    Dir.glob(File.join(ROOT, "_posts", "**", "*.{md,html}")).each do |path|
      assert_match(/\A\d{4}-\d{2}-\d{2}-.+\.(md|html)\z/, File.basename(path),
                   "#{relative(path)} needs a YYYY-MM-DD- prefix or Jekyll won't publish it")
    end
  end

  def test_link_tags_point_at_existing_files
    content_files.each do |path|
      File.read(path).scan(/\{%-?\s*link\s+(\S+)\s*-?%\}/).flatten.each do |target|
        assert File.exist?(File.join(ROOT, target)), "#{relative(path)} links to missing file #{target}"
      end
    end
  end
end
