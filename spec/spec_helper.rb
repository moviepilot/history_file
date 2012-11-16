require 'rubygems'
require 'spork'
require 'simplecov'
SimpleCov.start
require 'bundler'
Bundler.require

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  # require File.expand_path("../../config/environment", __FILE__)
  #require 'capybara/poltergeist'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[File.expand_path("../../spec/support/**/*.rb", __FILE__)].each {|f| require f}

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures

  end

  module TestResponseExtensions
    def json_body
      JSON.parse(self.body)
    end

    def unauthorized?
      code.to_i == 401
    end
  end

  def expect_id_and_return(id, ret_val)
    lambda { |id| id.to_s.should == id.to_s; ret_val }
  end

end

require File.expand_path("../../lib/history_file/", __FILE__)

# Spork.each_run do
#   FactoryGirl.reload
# end
