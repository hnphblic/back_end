# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"
describe 'system_controller' do
  def app
    SystemController.new
  end
  it 'index method' do
    get '/'
    expect(last_response).to be_ok
  end

  # Describle: These unit test using for api '/check_network'
  describe '/check_network' do
    context 'check network success' do
      before do
        get '/check_network'
      end
      # Call api success
      include_examples 'success_api'
    end
  end

  # Describle: These unit test using for api '/set_internal_network'
  # describe '/set_internal_network' do
  #   context 'set internal network success' do
  #     data = {
  #       internal: '127.0.0.1'
  #     }
  #     before do
  #       post '/set_internal_network'
  #     end
  #     # Call api success
  #     include_examples 'success_api'
  #   end
  # end

  # Describle: These unit test using for api '/master_division'
  describe '/master_division' do
    context 'master division success' do
      before do
        get '/master_division'
      end
      # Call api success
      include_examples 'success_api'
    end
  end

  # Describle: These unit test using for api '/approval_policy'
  describe '/approval_policy' do
    context 'approval policy success' do
      before do
        get '/approval_policy'
      end
      # Call api success
      include_examples 'success_api'
    end
  end

  # Describle: These unit test using for api '/service_policy'
  describe '/service_policy' do
    context 'service policy success' do
      before do
        get '/service_policy'
      end
      # Call api success
      include_examples 'success_api'
    end
  end
end
