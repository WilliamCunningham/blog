# frozen_string_literal: true

require "rake/testtask"

SITE_DIR = "_site"

desc "Build the site the way GitHub Actions does (production environment)"
task :build do
  sh({ "JEKYLL_ENV" => "production" }, "bundle exec jekyll build --strict_front_matter")
end

Rake::TestTask.new(:unit) do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.warning = false
end

desc "Check the built site for broken internal links, images and scripts"
task :proof do
  require "html-proofer"

  HTMLProofer.check_directory(
    SITE_DIR,
    disable_external: ENV["EXTERNAL"] != "1",
    enforce_https: true,
    ignore_status_codes: [403, 429, 999], # LinkedIn/X/Amazon block bots
    ignore_urls: [%r{\Ahttps://(www\.)?(linkedin|twitter|x)\.com}],
    swap_urls: { %r{\Ahttps://www\.williamcunningham\.com} => "" }
  ).run
end

desc "Build, then run unit tests and HTML checks (EXTERNAL=1 also checks external links)"
task test: %i[build unit proof]

task default: :test
