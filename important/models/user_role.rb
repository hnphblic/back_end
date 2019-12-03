# frozen_string_literal: true

# Connect user_role table
class UserRole < ActiveRecord::Base
  self.table_name = 'user_role'
  self.primary_key = :user_id
  validates :money, presence: true

  before_save :update_time

  private

  def update_time
    self.update_date = Time.now
  end
end
