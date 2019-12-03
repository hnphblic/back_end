# frozen_string_literal: true

require 'composite_primary_keys'

# This class to connect System_param_value table
class SystemParamValue < ActiveRecord::Base
  self.table_name = 'system_param_value'
  self.primary_keys = :system_param_id, :sort_order
end
