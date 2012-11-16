# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "history_file"
  gem.homepage = "http://github.com/moviepilot/history_file"
  gem.license = "MIT"
  gem.summary = %Q{A File like class with history support}
  gem.description = %Q{A File like class that supports versioning by date and has a fallback to older files}
  gem.email = "jannis@moviepilot.com"
  gem.authors = ["Jannis Hermanns"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end


