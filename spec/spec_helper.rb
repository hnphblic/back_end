# frozen_string_literal: true

require 'rubygems'
require 'bundler'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'rack/test'
require 'yaml'
require 'pry'
require 'rspec'
require 'simplecov'
SimpleCov.start do
  add_filter '/lib'
  add_filter '/helpers'
  add_filter '/controllers/email_controller.rb'
  add_group 'Models', 'filezen/models/'
  add_group 'Controllers', 'filezen/controllers/'
  add_group 'Spec', '/spec'
end
# set test environment

Dir.glob('./spec/support/**/*.rb').each { |f| require f }
Dir.glob('./filezen/controllers/*.rb').each { |f| require f }
Dir.glob('./filezen/models/*.rb').each { |f| require f }
Dir.glob('./filezen/helpers/*.rb').each { |f| require f }
# establish in-memory database for testing

# DataMapper.setup(:default, 'postgresql')

RSpec.configure do
  db_config = YAML.load_file('config/database.yml')
  ActiveRecord::Base.establish_connection(db_config['test'])
  set :environment, :test
  set :run, false
  set :raise_errors, true
  set :raise_errors_for_deprecations, true
  set :logging, false
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include CommonHelper
  config.include UserHelper
  config.include JwtHelper
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.raise_errors_for_deprecations!
  # config.action_controller.default_url_option = {host: ''}
  # config.disable_monkey_patching!
  # config.warnings = true
  # if config.files_to_run.one?
  #   config.default_formatter = 'doc'
  # end
  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end
