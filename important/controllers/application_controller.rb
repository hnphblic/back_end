# frozen_string_literal: true

require 'yaml'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/contrib'
require 'sinatra/strong-params'
require 'resolv'
require 'pry'
Dir.glob('./filezen/{helpers,models}/*.rb').each { |file| require file }

# Abstract class controller
class ApplicationController < Sinatra::Base
  register Sinatra::StrongParams
  register Sinatra::Reloader
  helpers RenderHelper
  helpers UserHelper
  helpers JwtHelper
  helpers EmailService
  helpers ValidateHelper
  helpers CommonHelper
  helpers FileHelper
  set :bind, '0.0.0.0'
  set :views, './views'
  configure do
    # enable CORS
    enable :cross_origin
    db_config = YAML.load_file('config/database.yml')
    ActiveRecord::Base.establish_connection(db_config['development'])
    ActiveRecord::Base.default_timezone = :utc
    # load locales file
    I18n.load_path = Dir.glob('./filezen/locales/*.yml')
    # set locale
    I18n.locale = :en
    set :root, './'
  end

  configure :production, :development do
    FileUtils.touch './log/stdout.log' unless File.exist?('./log/stdout.log')
    file_log = File.new('./log/stdout.log', 'a+')
    logger_out = Logger.new(file_log, 10, 100 * 1024)
    file_log.sync = true
    set :logger, logger_out
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Authorization'] = env['HTTP_AUTHORIZATION'] || ''
    response.header['Access-Control-Expose-Headers'] = %w[* Authorization]
    content_type :json, charset: 'utf-8'
    # puts 'From client ip: ' + request.ip
    # puts 'From host name: ' + request.host
    # puts 'From host IP:'
    # @server_ip = Resolv.getaddresses(request.host)
    # @server_name = Resolv.getnames(@server_ip[0])
    # puts @server_ip
    # puts @server_name

    # Using to logging start actions
    settings.logger.info("#{request.ip} using method #{request.request_method} #{request.path}")
  end

  options '*' do
    response.headers['Allow'] = 'GET, POST, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token, Access-Control-Allow-Origin, Cache-control, Pragma, Expires'
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.header['Cache-control'] = 'max-age=0, no-store'
    response.header['Pragma'] = 'no-cache'
    response.header['Expires'] = '0'
    200
  end

  set :needs do |*needed|
    condition do
      if @params.nil? || @params.blank? && !needed.blank?
        result = helper_render_message(
          400,
          format(I18n.t('common.errors.missing_params'), needed),
        )
        halt result[:status], result[:response].to_json
      else
        # make sure it's a symbol
        needed     = needed.map(&:to_sym)
        sym_params = @params.dup

        # symbolize the keys so we know what we're looking at
        sym_params.keys.each do |key|
          sym_params[(begin
                        key.to_sym
                      rescue
                        key
                      end) || key] = sym_params.delete(key)
        end

        if needed.any? { |key| sym_params[key].nil? || sym_params[key].blank? }
          result = helper_render_message(
            400,
            format(I18n.t('common.errors.missing_params'), needed),
          )
          halt result[:status], result[:response].to_json
        end
      end
    end
  end

  # set which params can use in api
  set(:allows) do |*passable|
    condition do
      unless @params.empty?
        globals  = settings.globally_allowed_parameters
        # make sure it's a symbol
        passable = (globals | passable).map(&:to_sym)
        # trim the params down
        @params = @params.select do |param, _value|
          passable.include?(param.to_sym)
        end
      end
    end
  end

  get '/' do
    'Api for Light Filezen'
  end

  # Authorized user when request to server
  # Input header['Authorization']
  # Return true if Authoration info match with user_session_info
  # Return true if Authoration info does not match with user_session_info
  def authorized?
    if headers['Authorization'].present?
      data = decrypt_jwt(headers['Authorization'])
      @current_user = UserInfo.is_present.where(id: data.first['id'].to_i).first
      return false if @current_user.blank?
      check_ip_address(request.ip, @current_user)
      token_current = @current_user.user_session_info.where(
        name: 'session_token',
      ).first
      return true if token_current.value == data.first['session_token']
    end
    false
  end

  # Authorized user when request to server
  # Input header['Authorization']
  # Return true if Authoration info match with user_session_info
  # Return true if Authoration info does not match with user_session_info
  def authorized_admin?
    if headers['Authorization'].present?
      data = decrypt_jwt(headers['Authorization'])
      @current_admin = AdminInfo.is_present.where(id: data.first['id'].to_i).first
      return false if @current_admin.blank?
      token_current = @current_admin.user_session_info.where(
        name: 'session_token_admin',
      ).first
      return true if token_current.value == data.first['session_token_admin']
    end
    false
  end

  # Using to denied access of user if do not pass authorization
  def access_denied
    return if request.request_method == 'OPTIONS'
    result = helper_render_message(
      401,
      I18n.t('common.errors.access_denied'),
    )
    halt result[:status], result[:response].to_json
  end

  def convert_params
    # json parse and convert key of params from string to symbol
    begin
      data = request.body.read
      return if data.blank?
      info_body = JSON.parse(data) if request.request_method == 'POST'
    rescue StandardError => e
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
      )
      halt result[:status], result[:response].to_json
    end
    return if info_body.blank?
    @params = info_body.each_with_object({}) do |(key, val), obj|
      obj[key.to_sym] = val
    end
  end
end
