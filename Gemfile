# frozen_string_literal: true

source 'https://rubygems.org'

gem 'activesupport'

gem 'sinatra'
gem 'sinatra-activerecord'
gem 'sinatra-contrib'
gem 'sinatra-cross_origin'
# gem 'sinatra-activerecord-rake'
gem 'activerecord'
gem 'sinatra-strong-params', require: 'sinatra/strong-params'
gem 'yajl-ruby', '1.4.1', require: 'yajl'

gem 'thin'
gem 'tilt-jbuilder'

gem 'bcrypt'
gem 'i18n'
gem 'jwt'
gem 'rake'
# gem 'sinatra-strong-params'
group :production do
  gem 'unicorn'
end
group :development do
  gem 'pry'
  gem 'rubocop'
end

group :test, :development do
  gem 'rack-test'
  gem 'rspec'
  gem 'simplecov', require: false
end

# Using to add PK include 2 fields
gem 'composite_primary_keys'
# Using to solve File
gem 'fileutils'
# AD Authorization
gem 'net-ldap', require: 'net/ldap'
# Using to zip file
gem 'rubyzip', '>= 1.0.0'
gem 'zip-zip'
# Using to call api in another service
gem 'rest-client'
# Using to control log
gem 'logger'
# Using to preview archive file
gem 'ffi'
gem 'ffi-libarchive'
gem 'magic'
# gem 'rmagick'
