# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"
describe 'user_info model' do
  before(:each) do
    @user = UserInfo.where(username: 'tonydo').first
  end

  it 'user should exist' do
    expect(@user.present?).to eq(true)
  end

  # specify 'should require a title' do
  #   post = Post.new
  #   post.should_not be_valid
  #   post.errors[:title].should include('Title must not be blank')
  # end

  # specify 'should support to_json export' do
  #   JSON.parse(@post.to_json).should == { 'id' => 1, 'text' => 'Hello world', 'title' => 'test post', 'user' => { 'id' => 1, 'name' => 'Test1', 'email' => 'toto1@toto.com' } }
  # end
end
