# frozen_string_literal: true

require 'rubygems'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/base'
require 'sinatra/cross_origin'
require 'resolv'

require_relative 'filezen/logic/user_logic'

# require router-controller
# Dir["filezen/controllers/*.rb"].each{ |file| require_relative file}

module LightFileZen
  class AppServices < Sinatra::Base
    set :bind, '0.0.0.0'
    user_logic = LightFileZen::Logic::UserLogic.new

    configure do
      enable :cross_origin # enable CORS
      db_config = YAML.load_file('config/database.yml')
      ActiveRecord::Base.establish_connection(db_config['development'])
      # ActiveRecord::Schema.define do
      #  create_table :users do |t|
      #    t.string :user_id, null: false
      #    t.string :name
      #    t.string :email
      #    t.string :phone
      #    t.string :login
      #    t.string :avata
      #    t.string :password
      #    t.datetime :created_at, null: false
      #    t.datetime :updated_at, :null => false
      #  end
      # add_index :users, :email
      # end
    end
    # Allow CORS request
    before do
      response.headers['Access-Control-Allow-Origin'] = '*'
      puts 'From client ip: ' + request.ip
      puts 'From host name: ' + request.host
      puts 'From host IP:'
      @server_ip = Resolv.getaddresses(request.host)
      @server_name = Resolv.getnames(@server_ip[0])
      puts @server_ip
      puts @server_name
    end

    options '*' do
      response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override,access-control-allow-origin, access-control-allow-methods, Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token'
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Allow'] = 'HEAD,GET,PUT,DELETE,OPTIONS,POST'
      response.headers['Access-Control-Allow-Methods'] = 'HEAD,GET,PUT,POST,DELETE,OPTIONS'
      200
    end
    
  end
end
