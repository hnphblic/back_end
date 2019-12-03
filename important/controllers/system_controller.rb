# frozen_string_literal: true

require_relative './application_controller.rb'

# Control System action
class SystemController < ApplicationController
  before do
  end

  # Get all system params
  get '/' do
    begin
      system_params = {}
      list_params = SystemParam.all
      list_params.each do |sys_param|
        system_params[sys_param.name.to_sym] = system_param_value_sorted(sys_param.name).first.value
      end
      result = helper_render_message(
        200,
        I18n.t('common.success.congrate'),
        system_params: system_params,
      )
    rescue StandardError => e
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
        system_params: system_params,
      )
    end
    halt result[:status], result[:response].to_json
  end

  # Using to check network is inside or outside
  get '/check_network' do
    begin
      # data = {
      #   sender_address: 'lovemaxvn@gmail.com',
      #   subject: 'test',
      #   body: 'test',
      # }
      # send_email_test(data)
      net_work = check_inside(request.ip)
      result = helper_render_message(
        200,
        I18n.t('common.success.congrate'),
        is_inside: net_work,
      )
    rescue StandardError => e
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
      )
    end
    halt result[:status], result[:response].to_json
  end

  # get all value in master_division table
  get '/master_division' do
    begin
      division = MasterDivision.all
      result = helper_render_message(
        200,
        I18n.t('common.success.congrate'),
        master_division: division,
      )
    rescue StandardError => e
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
        system_params: system_params,
      )
    end
    halt result[:status], result[:response].to_json
  end

  # get all value in approval_policy table
  get '/approval_policy' do
    begin
      network = check_inside(request.ip) ? 0 : 1
      policy = ApprovalPolicy.find(network)
      result = helper_render_message(
        200,
        I18n.t('common.success.congrate'),
        approval_policy: policy,
      )
      unless policy.present?
        result = helper_render_message(
          400,
          I18n.t('system_controller.errors.approval_policy'),
        )
      end
    rescue StandardError => e
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
        system_params: system_params,
      )
    end
    halt result[:status], result[:response].to_json
  end

  # get all value inservice_policy table
  get '/service_policy' do
    begin
      network = check_inside(request.ip) ? 0 : 1
      list_service_value = []
      Service.all.each do |service|
        policy = service.service_policy.where(system_id: network).first
        list_service_value << {
          name: service.name,
          status: policy.status,
          priority: policy.priority,
        }
      end
      result = helper_render_message(
        200,
        I18n.t('common.success.congrate'),
        services: list_service_value,
      )
    rescue StandardError => e
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
      )
    end
    halt result[:status], result[:response].to_json
  end

  # Using to set value for internal network
  # Processing
  # post '/set_internal_network', needs: %i[internal] do
  #   re_check_internal = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/
  #   unless re_check_internal.match params[:internal]
  #     result = helper_render_message(
  #       400,
  #       I18n.t('common.errors.invalid_params'),
  #     )
  #     halt result[:status], result[:response].to_json
  #   end
  #   # split_internal = params[:internal].split('.')
  #   # re = "^#{split_internal[0]}\.#{split_internal[1]}\.#{split_internal[2]}\.\d{1,3}$"
  # end
end
