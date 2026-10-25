# frozen_string_literal: true

require "test_helper"
require "nokogiri"

# Checks the generated site in _site/. Run `rake build` (or `rake test`) first.
class SiteTest < Minitest::Test
  def setup
    skip "_site/ not built — run `bundle exec rake test`" unless Dir.exist?(SITE)
  end

  def pages
    @pages ||= Dir.glob(File.join(SITE, "**", "*.html")).to_h do |path|
      [path.delete_prefix(SITE), Nokogiri::HTML5(File.read(path))]
    end
  end

  def test_every_page_has_a_title_and_one_h1
    pages.each do |path, doc|
      refute_empty doc.at("title")&.text.to_s.strip, "#{path} has no <title>"
      assert_equal 1, doc.css("h1").size, "#{path} should have exactly one <h1>"
    end
  end

  def test_every_page_declares_language_and_csp
    pages.each do |path, doc|
      assert_equal "en", doc.at("html")["lang"], "#{path} is missing <html lang>"
      csp = doc.at('meta[http-equiv="Content-Security-Policy"]')
      refute_nil csp, "#{path} is missing the Content-Security-Policy meta tag"
      refute_includes csp["content"], "unsafe-inline", "#{path} CSP must not allow unsafe-inline"
    end
  end

  # The CSP blocks inline scripts, event handlers and style attributes,
  # so anything like that in a template or post would silently break.
  def test_no_inline_code_that_the_csp_would_block
    pages.each do |path, doc|
      doc.css("script:not([src])").each do |script|
        assert_equal "application/ld+json", script["type"], "#{path} has an inline <script> the CSP will block"
      end
      assert_empty doc.xpath("//@*[starts-with(name(), 'on')]").map(&:name), "#{path} has inline event handlers"
      assert_empty doc.css("[style]"), "#{path} has style= attributes the CSP will block"
    end
  end

  def test_images_have_alt_text
    pages.each do |path, doc|
      doc.css("img:not([alt])").each { |img| flunk "#{path}: <img src=#{img['src']}> needs alt text" }
    end
  end

  def test_feed_and_sitemap_are_generated
    assert File.exist?(File.join(SITE, "feed.xml")), "feed.xml missing"
    sitemap = File.read(File.join(SITE, "sitemap.xml"))
    assert_includes sitemap, "https://www.williamcunningham.com/coding_notes/"
    refute_includes sitemap, "404", "404 page should not be in the sitemap"
  end

  def test_repo_files_are_not_published
    %w[readme/index.html Gemfile Rakefile test 2024-11-29-rails-form-error-handling.md.txt].each do |file|
      refute File.exist?(File.join(SITE, file)), "#{file} should be excluded from the site"
    end
  end

  def test_posts_show_their_date
    post = Dir.glob(File.join(SITE, "2024", "**", "index.html")).first
    doc = Nokogiri::HTML5(File.read(post))
    refute_nil doc.at("article time[datetime]"), "#{post} should show the post date"
  end
end
