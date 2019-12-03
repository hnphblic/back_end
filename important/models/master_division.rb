# frozen_string_literal: true

require 'composite_primary_keys'
# Connect master_division table
class MasterDivision < ActiveRecord::Base
  self.table_name = 'master_division'
  self.primary_keys = :division_kind_num, :division_value
  validates :division_kind_num, presence: true
  validates :division_kind_name, presence: true
  validates :division_value, presence: true
  validates :division_name_ja, presence: true
  validates :division_name_en, presence: true

  scope :status_defender, -> { where(division_kind_num: 1) }
  scope :status_cleaner, -> { where(division_kind_num: 2) }
  scope :status_request, -> { where(division_kind_num: 3) }
  scope :status_history, -> { where(division_kind_num: 4) }

  # Assocaitions
end
