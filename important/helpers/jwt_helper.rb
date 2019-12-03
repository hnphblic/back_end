# frozen_string_literal: true

require 'jwt'
module JwtHelper
  HMAC_SECRET = 'sms'
  def encrypt_jwt(data)
    JWT.encode data, HMAC_SECRET, 'HS256'
  end

  def decrypt_jwt(data)
    JWT.decode data, HMAC_SECRET, true, algorithm: 'HS256'
  end
end
