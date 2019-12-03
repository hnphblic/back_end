# frozen_string_literal: true

# Connect system_param table
class SystemParam < ActiveRecord::Base
  self.table_name = 'system_param'
  has_many :system_param_values, foreign_key: :system_param_id
end
