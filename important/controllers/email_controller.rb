# frozen_string_literal: true

# Control Email action
class EmailController < ApplicationController
  set :no_auth_needs, %w[]
  set :no_convert_params, %w[]
  before do
    unless settings.no_auth_needs.include?(env['PATH_INFO']) || authorized?
      access_denied
    end
    unless settings.no_convert_params.include?(env['PATH_INFO'])
      convert_params
    end
  end

  post '/noti_upload_info', needs: %i[list_file] do
    begin
      sys_noti = system_param_value_sorted('email_notification').first.value
      unless true?(sys_noti)
        result = helper_render_message(
          200,
          I18n.t('common.success.congrate'),
        )
        halt result[:status], result[:response].to_json
      end
      list_file = Files.is_present.where(id: params[:list_file])
      content_email = "Upload Info: \n"
      list_file.each do |file|
        content_email += "\t- #{file.name}: "
        list_service = Service.where('id not in (?)', [1])
        list_service.each do |service|
          status = file.file_service.where(service_id: service.id).first.value
          status_str = MasterDivision.status_cleaner.where(division_value: status).first.division_name_en
          content_email += "\t\t+ #{service.name}: #{status_str}\n"
        end
      end
      data = {
        sender_address: '',
        sender_name: 'FileZen Admin',
        to: @current_user.email,
        subject: '[FileZen S] Status upload',
        body: content_email,
      }
      send_email(data)
    rescue StandardError => e
      render_rescue e
    ensure
      result = helper_render_message(
        200,
        I18n.t('common.success.congrate'),
      )
    end
    halt result[:status], result[:response].to_json
  end

  post '/noti_approval_info', needs: %i[list_file] do
    begin
      sys_noti = system_param_value_sorted('email_notification').first.value
      unless true?(sys_noti)
        result = helper_render_message(
          200,
          I18n.t('common.success.congrate'),
        )
        halt result[:status], result[:response].to_json
      end
      list_file_by_user = Files.is_present.where(id: params[:list_file]).all.group_by(&:user_id_upload)
      list_file_by_user.each do |_user_id, user_file|
        content_email = "Approval Info: \n"
        user_file.each do |file|
          status = file.request.status
          status_str = MasterDivision.status_request.where(division_value: status).first.division_name_en
          content_email += "\t- #{file.name}: #{status_str}"
        end
        data = {
          sender_address: '',
          sender_name: 'FileZen Admin',
          to: @current_user.email,
          subject: '[FileZen S] Status approval',
          body: content_email,
        }
        send_email(data)
      end
    rescue StandardError => e
      render_rescue e
    ensure
      result = helper_render_message(
        200,
        I18n.t('common.success.congrate'),
      )
    end
    halt result[:status], result[:response].to_json
  end
end
