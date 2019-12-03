# frozen_string_literal: true

module ValidateHelper
  EMAIL_REGEX = /\A([\w+\-]\.?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i.freeze

  def help_valid_email?(email)
    !(email =~ EMAIL_REGEX).blank?
  end

  def help_valid_password?(password)
    password.length >= 8
  end

  def check_max_lenght(value, max_lenght)
    value.size <= max_lenght
  end
end
