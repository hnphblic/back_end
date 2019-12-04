# frozen_string_literal: true

require 'rubygems'
require 'sinatra'

Dir.glob('./important/{helpers,controllers}/*.rb').each { |file| require file }

version = '/api/v1'

map("#{version}/users") { run UserController }
map("#{version}/admin") { run AdminController }
map("#{version}/system") { run SystemController }
map("#{version}/modem") { run ModemController }
map(version) { run ApplicationController }
