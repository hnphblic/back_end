# frozen_string_literal: true

require 'composite_primary_keys'
# Connect file_service table
class Modem < ActiveRecord::Base
  self.table_name = 'modem'
  validates :name, presence: true
  
  # Assocaitions
  has_one :phone, foreign_key: :id_modem, dependent: :destroy

  before_save :update_time

  private

  def update_time
    self.update_date = Time.now
  end
end
