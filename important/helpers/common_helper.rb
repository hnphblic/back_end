# frozen_string_literal: true

require 'uri'
module CommonHelper
  # Input name of system_params
  # Output List param value of system_params was sorted
  def system_param_value_sorted(name)
    sys = SystemParam.where(name: name).first
    sys.system_param_values.order(:sort_order)
  end

  def true?(obj)
    obj.to_s.downcase == 'true'
  end

  # Using to add element in an array
  # If have keyword to search, return array with search condition
  # only search on filed of element in fields param
  # Input:
  # - Array: arr - array result
  # - Hash: element - object
  # - Array: fields - field to search
  # - String: keyword
  def add_element_search(arr, element, fields, keyword)
    if keyword.present?
      keyword = URI.decode_www_form_component(keyword)
      matched = fields.any? { |k, _v| element[k].to_s.downcase.include? keyword.downcase }
      arr << element if matched
    else
      arr << element
    end
    arr
  end

  # Input: DateTime: date_time
  def convert_format_date_time(date_time, time_zone = '0000')
    time_zone.gsub!(' ', '+')
    DateTime.parse(date_time.to_s).new_offset(time_zone).strftime('%Y/%m/%d %H:%M:%S')
  rescue StandardError => e
    render_rescue e
    DateTime.parse(date_time.to_s).strftime('%Y/%m/%d %H:%M:%S')
  end
end
