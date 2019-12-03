# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"
describe 'file_history_controller' do
  def app
    FileHistoryController.new
  end

  # Describe: These unit test are using for api '/history_upload'
  describe '/history_upload' do
    include_context 'generate_authorized', 'tonydo'
    # Check when get history upload of user is success
    context 'when get  history upload of user is success' do
      before do
        get '/history_upload', nil, 'HTTP_AUTHORIZATION' => session_token
      end
      # Call api success
      include_examples 'success_api'
    end

    # When get history upload of user fail
    context 'when get file history of user is fail' do
      # Get history upload is failure because of missing authorization
      context 'missing Authorization when get file history of user' do
        before do
          get '/history_upload'
        end
        include_examples 'unauthorized'
      end
    end
  end
end
