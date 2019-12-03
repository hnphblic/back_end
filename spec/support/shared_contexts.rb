# frozen_string_literal: true

RSpec.shared_context 'authorized' do
  data = { username: 'testuser1', password: 'Testuser123@' }
  before do
    post '/login', data.to_json
  end
  let(:response) { JSON.parse(last_response.body) }
  let(:current_user) { UserInfo.where(username: 'testuser1').first }
  let(:session_token) { response['extra']['jwt'] }
end

RSpec.shared_context 'generate_authorized' do |user_name|
  user = UserInfo.where(username: user_name).first
  token = user.user_session_info.where(name: 'session_token').first
  data_user = {
    id: user.id,
    name: user.name,
    is_inside: 0,
    screen_code: 0,
    session_token: token.value,
    flag_transfer: 0,
    switch_view: '0',
  }
  let(:current_user) { user }
  let(:session_token) { encrypt_jwt(data_user) }
end
