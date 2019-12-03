# frozen_string_literal: true

# Connect user_role table
class AdminRole < ActiveRecord::Base
  self.table_name = 'admin_role'
  self.primary_key = :admin_id

  before_save :update_time

  private

  def update_time
    self.update_date = Time.now
  end
end
