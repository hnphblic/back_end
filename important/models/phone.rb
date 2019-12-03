# frozen_string_literal: true

# Connect approval_policy table
class Phone < ActiveRecord::Base
  self.table_name = 'phone'
  self.primary_key = :id_modem, :number
  validates :id_modem, presence: true, uniqueness: true
  validates :number, presence: true, uniqueness: true
  validates :money, presence: true
  before_save :update_time

  private

  def update_time
    self.update_date = Time.now
  end
  # Assocaitions
end
