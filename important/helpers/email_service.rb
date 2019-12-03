# frozen_string_literal: true

module EmailService
  EMAIL_SERVICE_URL = 'localhost:9999/api/notification/email/send'
  def send_email_reset_password(data)
    result = helper_render_message(
      200,
      I18n.t('common.success.congrate'),
      data,
    )
    halt result[:status], result[:response].to_json
  end

  def send_email(data)
    begin
      body = {
        sender_address: data[:sender_address] || '',
        sender_name: data[:sender_name] || '',
        to: data[:to],
        subject: data[:subject],
        body: data[:body],
      }
      RestClient.put(EMAIL_SERVICE_URL, body)
    rescue StandardError => e
      render_rescue e
    ensure
      true
    end
    true
  end

  def send_email_test(data)
    # email(
    #   to: data[:sender_address] || '',
    #   from: 'anhdd2901@gmail.com',
    #   subject: data[:subject],
    #   body: data[:body],
    # )
  end
end
