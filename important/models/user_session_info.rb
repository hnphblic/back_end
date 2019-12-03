# frozen_string_literal: true

require 'composite_primary_keys'
# Connect user_session_info table
class UserSessionInfo < ActiveRecord::Base
  self.table_name = 'user_session_info'
  self.primary_keys = :user_id, :name
end
