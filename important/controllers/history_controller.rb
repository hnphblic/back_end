# frozen_string_literal: true

# Control File History action
class FileHistoryController < ApplicationController
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
  # Using to show list file uploaded
  # Input string: key_word(optional)
  get '/history_list' do
    begin
      @network = check_inside(request.ip) ? 0 : 1
      list_check_field = %i[file_name file_size status created_at comment_apply]
      list_file_upload = Files.is_present.joins(:request).where(
        user_id_upload: @current_user.id,
        request: {
          system_id_request: @network,
        },
      )
      list_result = []
      services = Service.all
      # add value of file service to list_service for each file
      list_file_upload.each do |file|
        list_service = {}
        file.file_service.each do |fs|
          service = services.select { |s| s.id == fs.service_id }.first
          list_service[service.name] = fs.value
        end
        request = file.request
        element = {
          file_id: file.id,
          file_name: file.real_name,
          file_size: file.convert_size,
          file_extension: file.extension,
          created_at: convert_format_date_time(file.create_date, params[:time_zone]),
          comment_apply: request.comment_request || '',
          status: request.status,
          list_service: list_service,
        }
        list_result = add_element_search(list_result, element, list_check_field, params[:key_word])
      end
      result = helper_render_message(
        200,
        I18n.t('common.success.congrate'),
        list_file: list_result,
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
end
