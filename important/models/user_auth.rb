# frozen_string_literal: true

require 'bcrypt'
# Connect user_auth table
class UserAuth < ActiveRecord::Base
  self.table_name = 'user_auth'
  self.primary_key = :user_id
  include BCrypt
  validates :password, presence: true
  validates :username_inside, presence: true, uniqueness: true
  validates :username_outside, presence: true, uniqueness: true
  def password_encrypt
    @password_encrypt ||= Password.new(password)
  end

  def password_encrypt=(new_password)
    @password_encrypt = Password.create(new_password)
    self.password = @password_encrypt
  end

  before_save :update_time

  private

  def update_time
    self.update_date = Time.now
  end
end
