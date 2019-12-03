# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/spec_helper"

describe 'main application' do
  def app
    ApplicationController.new
  end
  it 'should show the default index page' do
    get '/'
    expect(last_response).to be_ok
  end
end
