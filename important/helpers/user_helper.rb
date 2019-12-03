# frozen_string_literal: trueLF

require 'digest'
require 'securerandom'
module UserHelper
  def encrypt_sha_data(data)
    Digest::SHA256.hexdigest(data)
  end

  def check_sha_data(data, input_password)
    encrypt_sha_data(input_password) == data
  end

  # Using to check request from inside or outside network
  # Input: current ip address
  # Output: true/false
  def check_inside(ip)
    network_from = system_param_value_sorted('network_inside_from').first.value
    network_to   = system_param_value_sorted('network_inside_to').first.value
    network_from_ele = network_from.split('.')
    network_to_ele   = network_to.split('.')
    ip_ele = ip.split('.')
    format_regex = '^%s\.%s\.%s'
    reg = format(
      format_regex,
      network_from_ele[0],
      network_from_ele[1],
      network_from_ele[2],
    )
    if ip.match(reg) && network_from_ele[3].to_i <= ip_ele[3].to_i && network_to_ele[3].to_i >= ip_ele[3].to_i
      return true
    end
    false
  end

  # Input length
  # Output random string base64 with length = 4 * length /3
  def generate_random(length)
    SecureRandom.base64(length)
  end

  def generate_random_str(number)
    charset = Array('A'..'Z') + Array('a'..'z')
    Array.new(number) { charset.sample }.join
  end

  def check_ip_address(ip, user)
    if user.present? &&
       user.user_role.ip_access.present?
      list_ip = user.user_role.ip_access.split(',')
      unless list_ip.include? ip
        result = helper_render_message(
          401,
          I18n.t('common.errors.access_denied'),
          error_code: 'ERR_COM_0012',
        )
        halt result[:status], result[:response].to_json
      end
    end
  end
end
