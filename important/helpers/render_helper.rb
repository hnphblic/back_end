# frozen_string_literal: true

module RenderHelper
  # Using to format response message
  def helper_render_message(code_status, message, extra = {})
    result = {
      status: code_status,
      response: {
        common: {
          client_ip: request.ip,
        },
        message: message,
      },
    }
    result[:response][:extra] = extra if extra.present?
    result
  end

  def render_rescue(error)
    settings.logger.error "#{error.class}. Rescue: #{error.message}"
    error.backtrace.to_a.each { |e| settings.logger.error e.to_s }
  end

  def log_error_message(message)
    settings.logger.error message.to_s
  end

  def log_info_message(message)
    settings.logger.info message.to_s
  end

  def log_warn_message(message)
    settings.logger.warn message.to_s
  end
end
