if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end

require 'awesome_print'
require 'jekyll'
require_relative './spec_helper_simplecov.rb'
require './lib/push.rb'

RSpec.configure do |config|
  config.filter_run(focus: true)
  config.fail_fast = true
  config.run_all_when_everything_filtered = true
end

# Disabling the logs
Jekyll.logger.log_level = :error

# Create a Jekyll::Site instance, patched with a `file_by_name` method
def get_site(config = {}, options = {})
  default_options = {
    mock_write_method: true,
    process: true
  }
  options = default_options.merge(options)

  config = config.merge(
    'source' => fixture_path
  )
  config = Jekyll.configuration(config)

  site = AlgoliaSearchJekyllPush.init_options({}, options, config)
                                .jekyll_new(config)

  def site.file_by_name(file_name)
    each_site_file do |file|
      return file if file.path =~ /#{file_name}$/
    end
    nil
  end

  allow(site).to receive(:write) if options[:mock_write_method]

  site.process if options[:process]
  site
end

# Return the fixture path, according to the current Jekyll version being tested
def fixture_path
  jekyll_version = Jekyll::VERSION[0]
  fixture_path = "./spec/fixtures/jekyll_version_#{jekyll_version}"
  File.expand_path(fixture_path)
end

# Check the current Jekyll version
def restrict_jekyll_version(more_than: nil, less_than: nil)
  jekyll_version = Gem::Version.new(Jekyll::VERSION)
  minimum_version = Gem::Version.new(more_than)
  maximum_version = Gem::Version.new(less_than)

  return false if !more_than.nil? && jekyll_version < minimum_version
  return false if !less_than.nil? && jekyll_version > maximum_version
  true
end
