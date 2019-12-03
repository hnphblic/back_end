# frozen_string_literal: true

RSpec.shared_examples 'success_api' do
  it '' do
    expect(last_response).to be_ok
  end
end

RSpec.shared_examples 'failure_api' do
  it 'some thing when wrong' do
    expect(last_response.status).to eq(400)
  end
end

RSpec.shared_examples 'unauthorized' do
  it 'Unauthorized' do
    expect(last_response.status).to eq(401)
  end
end

RSpec.shared_examples 'common_response' do
  it 'response should include common' do
    response = JSON.parse(last_response.body)
    expect(response['common'].present?).to eq(true)
  end

  it 'response should include message' do
    response = JSON.parse(last_response.body)
    expect(response['message'].present?).to eq(true)
  end
end

RSpec.shared_examples 'extra_detail' do
  it 'response should include extra' do
    response = JSON.parse(last_response.body)
    expect(response['extra'].present?).to eq(true)
  end
end
