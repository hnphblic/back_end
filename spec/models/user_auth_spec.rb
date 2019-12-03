# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"
describe 'user_info model' do
  context 'validate model' do
    let(:user_auth) { UserAuth.first }
    before do
      @old_name_inside = user_auth.username_inside
      @update_time_current = user_auth.update_date
      user_auth.update(username_inside: 'test')
    end
    it 'update time should greater than update time current' do
      expect(user_auth.update_date.to_i).to be > @update_time_current.to_i
    end
    after do
      user_auth.update(username_inside: @old_name_inside)
    end
  end
end
