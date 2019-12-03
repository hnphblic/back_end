# frozen_string_literal: true

# Connect file_history table
class History < ActiveRecord::Base
  self.table_name = 'history'

  validates :user_id, presence: true
  validates :SendPhone, presence: true
  validates :ReceivePhone, presence: true
  validates :Status, presence: true
  validates :FristMoney, presence: true
  validates :LastMoney, presence: true
  validates :SendMoney, presence: true
  # Assocaitions
end
