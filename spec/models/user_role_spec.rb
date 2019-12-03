# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"
describe 'user_info model' do
  context 'validate model' do
    let(:user_role) { UserRole.first }
    before do
      @old_quota = user_role.quota
      @update_time_current = user_role.update_date
      user_role.update(quota: -1)
    end
    it 'update time should greater than update time current' do
      expect(user_role.update_date.to_i).to be > @update_time_current.to_i
    end
    after do
      user_role.update(quota: @old_quota)
    end
  end
end
