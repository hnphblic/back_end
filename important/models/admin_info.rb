# frozen_string_literal: true

# Connect user_info table
class AdminInfo < ActiveRecord::Base
  self.table_name = 'admin_info'
  validates :username, uniqueness: true

  # Assocaitions
  has_one :admin_role, foreign_key: :admin_id, dependent: :destroy
  has_many :user_session_info, foreign_key: :user_id, dependent: :destroy
  
  before_save :update_time

  scope :is_present, -> { where(is_deleted: false) }

  private

  def update_time
    self.update_date = Time.now
  end
end
