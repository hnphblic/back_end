# frozen_string_literal: true

require "#{File.dirname(__FILE__)}/../spec_helper"
# Dir.glob('./filezen/helpers/*.rb').each { |f| require f }

# RSpec.configure do |c|

# end

describe 'UserController' do
  before do
    @user_tmp = UserInfo.where(username: 'testuser1').first
  end
  def app
    UserController.new
  end

  # Describe: These unit test are using for api '/login'
  describe '/login' do
    # Check for login success
    context 'when login success' do
      before do
        data = { username: 'testuser1', password: 'Testuser123@' }
        post '/login', data.to_json
        @user = UserInfo.where(username: 'testuser1').first
        @token = @user.user_session_info.where(name: 'session_token').first
      end
      include_examples 'success_api'
      include_examples 'extra_detail'
      
      it 'should change session token' do
        new_token = @user.user_session_info.where(name: 'session_token').first
        expect(new_token.value) != @token.value
      end

      it 'should contain jwt token' do
        response = JSON.parse(last_response.body)
        expect(response['extra']['jwt'].present?).to eq(true)
      end
    end

    context 'user inside login success' do
      before do
        SystemParamValue.where(system_param_id: 60).update(
          value: '127.0.0.0',
        )
        SystemParamValue.where(system_param_id: 61).update(
          value: '127.0.0.255',
        )
        data = { username: 'userInside', password: 'userInside123@' }
        post '/login', data.to_json
        @user = UserInfo.where(username: 'userInside').first
        @token = @user.user_session_info.where(name: 'session_token').first
        SystemParamValue.where(system_param_id: 60).update(
          value: '10.0.1.0',
        )
        SystemParamValue.where(system_param_id: 61).update(
          value: '10.0.4.255',
        )
      end
      include_examples 'success_api'
      include_examples 'extra_detail'

      it 'should change session token' do
        new_token = @user.user_session_info.where(name: 'session_token').first
        expect(new_token.value) != @token.value
      end

      it 'should contain jwt token' do
        response = JSON.parse(last_response.body)
        expect(response['extra']['jwt'].present?).to eq(true)
      end
    end

    context 'login when user not inside and network inside' do
      before do
        # Set network inside
        SystemParamValue.where(system_param_id: 60).update(
          value: '127.0.0.0',
        )
        SystemParamValue.where(system_param_id: 61).update(
          value: '127.0.0.255',
        )
        data = { username: 'userInside1', password: 'userInside123@' }
        post '/login', data.to_json
        SystemParamValue.where(system_param_id: 60).update(
          value: '10.0.1.0',
        )
        SystemParamValue.where(system_param_id: 61).update(
          value: '10.0.4.255',
        )
      end
      include_examples 'failure_api'
      it 'should return error message' do
        response = JSON.parse(last_response.body)
        expect(response['message']).to eq('Cannot connect to AD Authorization')
      end
    end

    context 'login when user not outside and network not inside' do
      before do
        data = { username: 'userOutside', password: 'userOut123@' }
        post '/login', data.to_json
      end
      include_examples 'failure_api'
      it 'should return error message' do
        response = JSON.parse(last_response.body)
        expect(response['message']).to eq('Cannot connect to AD Authorization')
      end
    end

    context 'login when user admin not inside and network inside' do
      before do
        # Set network inside
        SystemParamValue.where(system_param_id: 60).update(
          value: '127.0.0.0',
        )
        SystemParamValue.where(system_param_id: 61).update(
          value: '127.0.0.255',
        )
        data = { username: 'hoandv', password: 'Luvina@123' }
        post '/login', data.to_json
        SystemParamValue.where(system_param_id: 60).update(
          value: '10.0.1.0',
        )
        SystemParamValue.where(system_param_id: 61).update(
          value: '10.0.4.255',
        )
      end
      include_examples 'success_api'
      it 'should return error message' do
        response = JSON.parse(last_response.body)
        expect(response['message']).to eq('Success')
      end
    end

    # Check for login fail
    context 'when login fail' do
      # Check for login fail when missing param
      context 'when missing params username' do
        before do
          data = { username: '', password: 'Testuser123@' }
          post '/login', data.to_json
        end
        include_examples 'failure_api'
        # Return message missing param
        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Missing params: [:username, :password]')
        end
      end

      # Check for login fail when missing param
      context 'when missing params username user inside' do
        before do
          SystemParamValue.where(system_param_id: 60).update(
            value: '127.0.0.0',
          )
          SystemParamValue.where(system_param_id: 61).update(
            value: '127.0.0.255',
          )
          data = { username: '', password: 'userInside123@' }
          post '/login', data.to_json
          SystemParamValue.where(system_param_id: 60).update(
            value: '10.0.1.0',
          )
          SystemParamValue.where(system_param_id: 61).update(
            value: '10.0.4.255',
          )
        end
        include_examples 'failure_api'
        # Return message missing param
        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Missing params: [:username, :password]')
        end
      end

      # Check for login fail when missing param
      context 'when missing params 1' do
        before do
          data = { username: 'testuser1', password: '' }
          post '/login', data.to_json
        end
        include_examples 'failure_api'
        # Return message missing param
        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Missing params: [:username, :password]')
        end
      end

      # Check for login fail when missing param
      context 'when missing params user inside' do
        before do
          SystemParamValue.where(system_param_id: 60).update(
            value: '127.0.0.0',
          )
          SystemParamValue.where(system_param_id: 61).update(
            value: '127.0.0.255',
          )
          data = { username: 'userInside', password: '' }
          post '/login', data.to_json
          SystemParamValue.where(system_param_id: 60).update(
            value: '10.0.1.0',
          )
          SystemParamValue.where(system_param_id: 61).update(
            value: '10.0.4.255',
          )
        end
        include_examples 'failure_api'
        # Return message missing param
        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Missing params: [:username, :password]')
        end
      end

      # Check for login fail when missing param
      context 'when missing params 2' do
        before do
          data = { username: '', password: '' }
          post '/login', data.to_json
        end
        include_examples 'failure_api'
        # Return message missing param
        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Missing params: [:username, :password]')
        end
      end

      # Check for login fail when missing param
      context 'when missing params user inside 2' do
        before do
          SystemParamValue.where(system_param_id: 60).update(
            value: '127.0.0.0',
          )
          SystemParamValue.where(system_param_id: 61).update(
            value: '127.0.0.255',
          )
          data = { username: '', password: '' }
          post '/login', data.to_json
          SystemParamValue.where(system_param_id: 60).update(
            value: '10.0.1.0',
          )
          SystemParamValue.where(system_param_id: 61).update(
            value: '10.0.4.255',
          )
        end
        include_examples 'failure_api'
        # Return message missing param
        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Missing params: [:username, :password]')
        end
      end

      context 'when missing user role' do
        before do
          # Prepare data for unit test. user.user_role.is_lock = true
          data = { username: 'UserMissingRole', password: 'UserMissingRole@' }
          post '/login', data.to_json
        end
        # Call api success but return error message
        include_examples 'success_api'
        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq("Missing user'role information")
        end
      end

      context 'when user is block' do
        before do
          # Prepare data for unit test. user.user_role.is_lock = true
          data = { username: 'testblock', password: 'Testuserblock@' }
          post '/login', data.to_json
        end
        # Call api success but return error message
        include_examples 'success_api'

        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Account is locked')
        end
      end

      context 'when user is expired' do
        before do
          data = { username: 'userexpired', password: 'Userexpired@' }
          post '/login', data.to_json
        end
        # Call api success but return error message
        include_examples 'success_api'

        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Account is expired')
        end
      end

      context 'when user is admin' do
        before do
          # Prepare data for unit test. user.user_role.is_admin = true
          data = { username: 'testadmin', password: 'Testadmin@' }
          post '/login', data.to_json
        end
        # Call api success but return error message
        include_examples 'success_api'

        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Not a user account')
        end
      end

      context 'user is deleted' do
        before do
          data = { username: 'testdeleted', password: 'Testdeleted@' }
          post '/login', data.to_json
        end
        # Call api success but return error message
        include_examples 'success_api'

        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Cannot found user')
        end
      end

      context 'when user blank' do
        before do
          data = { username: 'testuserblank', password: 'Test123@' }
          post '/login', data.to_json
        end
        # Call api success but return error message
        include_examples 'success_api'

        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Username or password is incorrect')
        end
      end

      context 'when user inside is blank' do
        before do
          SystemParamValue.where(system_param_id: 60).update(
            value: '127.0.0.0',
          )
          SystemParamValue.where(system_param_id: 61).update(
            value: '127.0.0.255',
          )
          data = { username: 'testuserblank', password: 'Test123@' }
          post '/login', data.to_json
          SystemParamValue.where(system_param_id: 60).update(
            value: '10.0.1.0',
          )
          SystemParamValue.where(system_param_id: 61).update(
            value: '10.0.4.255',
          )
        end
        # Call api success but return error message
        include_examples 'success_api'
        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Username or password is incorrect')
        end
      end

      context 'when param password matching with encrypt password' do
        before do
          data = { username: 'testuser1', password: '$2a$12$5vmGneeJH1F0FNjKCYiiHe0j/XNyQ9Y9Bd53xudO47Wfp4zVWiPCG' }
          post '/login', data.to_json
        end
        # Call api success but return error message
        include_examples 'success_api'

        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Username or password is incorrect')
        end
      end

      context 'when password is expired' do
        before do
          data = { username: 'UserPassExpired', password: 'UserPassExpired@' }
          post '/login', data.to_json
        end
        # Call api success but return error message
        include_examples 'success_api'
        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq("Account's password is expired")
        end
      end
    end
  end

  # Describe: These unit test are using for api '/request_need_to_approval'
  describe '/request_need_to_approval' do
    context 'success' do
      include_context 'generate_authorized', 'tonydo1'
      before do
        SystemParamValue.where(system_param_id: 60).update(
          value: '10.0.1.0',
        )
        SystemParamValue.where(system_param_id: 61).update(
          value: '10.0.4.255',
        )
        get '/request_need_to_approval', nil, 'HTTP_AUTHORIZATION' => session_token
      end
      it 'should be okay' do
        expect(last_response).to be_ok
      end
      it 'should have correct response' do
        response = JSON.parse(last_response.body)
        list_id_user_request = AssignApproval.where(
          user_id_approval: current_user.id,
        ).pluck(:user_id_request)
        list_request = Request.where(
          user_id_request: list_id_user_request,
          status: 1,
          system_id_request: 1,
        ).count
        expect(list_request).to eq(response['extra']['request_need_to_approval'])
      end
    end

    context 'when have no request need to approval' do
      include_context 'generate_authorized', 'request_need_to_approval'
      before do
        get '/request_need_to_approval', nil, 'HTTP_AUTHORIZATION' => session_token
      end
      # Return message because of this acc has no request to approve
      it 'should return message no request' do
        response = JSON.parse(last_response.body)
        expect(response['message']).to eq('Cannot found request need to approval')
      end
    end

    context 'failure' do
      context 'when missing Authorization' do
        include_context 'generate_authorized', 'tonydo1'
        before do
          get '/request_need_to_approval'
        end
        include_examples 'unauthorized'
        # Return message because of this acc has no request to approve
        it 'should return message no request' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Access denied')
        end
      end
    end
  end

  # Describe: These unit test are using for api '/check_valid_password'
  describe '/check_valid_password' do
    include_context 'authorized'
    context 'when success' do
      data = {
        old_pass: 'Testuser123@',
        new_pass: 'Hoilamchi1@',
        retype_pass: 'Hoilamchi1@',
      }
      before do
        post '/check_valid_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
      end
      include_examples 'success_api'
    end

    context 'when failure' do
      context 'size length' do
        # Prepare data to test. In this unit test, password is not valid because of password.length < 8
        before do
          data = {}
          password_level = system_param_value_sorted('password_level').first.value.to_i
          data[:old_pass] = 'Testuser123@'
          data[:new_pass] = password_level.positive? ? generate_random_str(password_level - 1) : 1
          data[:retype_pass] = data[:new_pass]
          post '/check_valid_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0003' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0003')
        end
      end

      # check_valid_password is failure because of new password contain only uppercase
      # Then return error message: ERR_COM_0008
      context 'contain only uppercase' do
        # Prepare data to test. In this unit test, password is not valid because of new pass contain only uppercase
        before do
          data = {}
          data[:old_pass] = 'Testuser123@'
          data[:new_pass] = 'ABCDEFGH'
          data[:retype_pass] = 'ABCDEFGH'
          post '/check_valid_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0008' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0008')
        end
      end

      # check_valid_password is failure because of new password contain only lowercase
      # Then return error message: ERR_COM_0008
      context 'contain only lowercase' do
        # Prepare data to test. In this unit test, password is not valid because of new pass contain only lowercase
        before do
          data = {}
          data[:old_pass] = 'Testuser123@'
          data[:new_pass] = 'abcdefgh'
          data[:retype_pass] = 'abcdefgh'
          post '/check_valid_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0008' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0008')
        end
      end

      # check_valid_password is failure because of new password do not contain number character
      # Then return error message: ERR_COM_0009
      context 'not contain number character' do
        # Prepare data to test. In this unit test, password is not valid because of new pass not contain number character
        before do
          data = {}
          data[:new_pass] = 'Abcdefgh'
          data[:retype_pass] = 'Abcdefgh'
          data[:old_pass] = 'Testuser123@'
          post '/check_valid_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0009' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0009')
        end
      end

      # check_valid_password is failure because of new password do not contain special character
      # Then return error message: ERR_COM_0010
      context 'not contain special character' do
        # Prepare data to test. In this unit test, password is not valid because of new pass not contain special chacter
        before do
          data = {}
          data[:new_pass] = 'Abcde123'
          data[:retype_pass] = 'Abcde123'
          data[:old_pass] = 'Testuser123@'
          post '/check_valid_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0010' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0010')
        end
      end

      # check_valid_password is failure because of old password do not matching with current password
      # Then return error message: ERR_COM_0011
      context 'not current pass' do
        # Prepare data to test. In this unit test, password is not valid because of old password do not matching with current password
        before do
          data = {}
          data[:new_pass] = 'Abcde123'
          data[:retype_pass] = 'Abcde123'
          data[:old_pass] = 'Testuser@123'
          post '/check_valid_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0011' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0011')
        end
      end

      # check_valid_password is failure because of new pass do not matching with retype pass
      # Then return error message: ERR_COM_0005
      context 'not matching with retype pass' do
        # Prepare data to test. In this unit test, password is not valid because of old password do not matching with current password
        before do
          data = {}
          data[:new_pass] = 'Abcde12@'
          data[:retype_pass] = 'Abcde12@4'
          data[:old_pass] = 'Testuser123@'
          post '/check_valid_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0005' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0005')
        end
      end

      # check_valid_password is failure because of new pass matching with current pass
      # Then return error message: ERR_COM_0004
      context 'matching with current pass' do
        # Prepare data to test. In this unit test, password is not valid because of old password do not matching with current password
        before do
          permit_previous_password = system_param_value_sorted('permit_previous_password')
          permit_previous_password.first.update value: 'FALSE'
          data = {}
          data[:new_pass] = 'Testuser123@'
          data[:retype_pass] = 'Testuser123@'
          data[:old_pass] = 'Testuser123@'
          post '/check_valid_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0004' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0004')
        end
      end

      # check_valid_password is failure because of missing param
      context 'missing param 1' do
        # Prepare data to test. In this unit test, missing param new_pass
        before do
          data = {}
          data[:retype_pass] = 'Testuser123@'
          data[:old_pass] = 'Testuser123@'
          post '/check_valid_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api fail because of missing param
        include_examples 'failure_api'
      end

      # check_valid_password is failure because of missing param
      context 'missing param 2' do
        # Prepare data to test. In this unit test, missing param retypepass
        before do
          data = {}
          data[:new_pass] = 'Testuser1234@'
          data[:old_pass] = 'Testuser123@'
          post '/check_valid_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api fail because of missing param
        include_examples 'failure_api'
      end

      # check_valid_password is failure because of missing param
      context 'missing param 3' do
        # Prepare data to test. In this unit test, missing param old_pass
        before do
          data = {}
          data[:new_pass] = 'Testuser1234@'
          data[:retype_pass] = 'Testuser1234@'
          post '/check_valid_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api fail because of missing param
        include_examples 'failure_api'
      end

      # check_valid_password is failure because of missing authorization
      context 'missing athorization' do
        # Prepare data to test. In this unit test, missing param old_pass
        before do
          data = {
            old_pass: 'Testuser123@',
            new_pass: 'Hoilamchi1@',
            retype_pass: 'Hoilamchi1@',
          }
          post '/check_valid_password', data.to_json
        end
        include_examples 'unauthorized'
        # Return messages Update failed because of missing authorization
        it 'should return msg update fail' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Access denied')
        end
      end

      # check_valid_password is failure because of data is null
      context 'data is null' do
        # Prepare data to test. In this unit test, missing param old_pass
        before do
          data = {}
          post '/check_valid_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api fail because of data is null
        include_examples 'failure_api'
        # Return messages Update failed because of data is null
        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Missing params: [:new_pass, :retype_pass, :old_pass]')
        end
      end
    end
  end

  # Describe: These unit test are using for api '/update user'
  describe '/update_user' do
    include_context 'authorized'
    # Check when update user success => include authorized and two param: name and email
    context 'when update user success' do
      context 'update name and email' do
        data = {
          name: 'Im Test User',
          email: 'testuser1@abc',
        }
        before do
          post '/update_user', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api success
        include_examples 'success_api'
        # Check message return: Success
        it 'should return msg Success' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Success')
        end
      end

      context 'update email only' do
        data = {
          email: 'testuser1@abc',
        }
        before do
          post '/update_user', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api success
        include_examples 'success_api'
        # Check messages return: Success
        it 'should return msg Success' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Success')
        end
      end

      context 'update name only' do
        data = {
          name: 'Im Test User',
        }
        before do
          post '/update_user', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api success
        include_examples 'success_api'
        # Check messages return: Success
        it 'should return msg Success' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Success')
        end
      end
    end

    # When update user fail
    context 'when update user fail' do
      # Update user is failure because of missing authorization
      context 'missing Authorization when update user' do
        before do
          post '/update_user'
        end
        include_examples 'unauthorized'
        # Return messages Update failed because of missing authorization
        it 'should return msg update fail' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Access denied')
        end
      end

      # Update user is failure because of name.length > 128
      context 'when name is invalid param' do
        data = {
          name: 'AAAAAAAAA1AAAAAAAAA2AAAAAAAAA3AAAAAAAAA4AAAAAAAAA5AAAAAAAAA6AAAAAAAAA7AAAAAAAAA8AAAAAAAAA9AAAAAAAAA1AAAAAAAAA2AAAAAAAAA3AAAAAAAAA4',
          email: 'testuser1@abc',
        }
        before do
          post '/update_user', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api failure because invalid Param - name is too long
        include_examples 'failure_api'
        # Return messages Update failed because of param is not valid
        it 'should return msg update fail' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Invalid params: name')
        end
      end

      # Update user is failure because of email.length > 128
      context 'when email is invalid param' do
        data = {
          name: 'Im Test User',
          email: 'AAAAAAAAA1AAAAAAAAA2AAAAAAAAA3AAAAAAAAA4AAAAAAAAA5AAAAAAAAA6AAAAAAAAA7AAAAAAAAA8AAAAAAAAA9AAAAAAAAA1AAAAAAAAA2AAAAAAAAA3AAAAAAAAA4@abc',
        }
        before do
          post '/update_user', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api failure because invalid Param - email is too long
        include_examples 'failure_api'
        # Return messages Update failed because of param is not valid
        it 'should return msg update fail' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Invalid params: email')
        end
      end
    end
  end

  # Describe: These unit test are using for api '/user_info'
  describe '/user_info' do
    include_context 'authorized'
    # Check when get user info is success
    context 'when get user info is success' do
      before do
        get '/user_info', nil, 'HTTP_AUTHORIZATION' => session_token
      end
      # Call api success
      include_examples 'success_api'
    end

    # When get user info fail
    context 'when get user info is fail' do
      # Get user info is failure because of missing authorization
      context 'missing Authorization when get user info' do
        before do
          get '/user_info'
        end
        include_examples 'unauthorized'
      end
    end
  end

  # Describe: These unit test are using for api '/get_user_role'
  describe 'get_user_role' do
    include_context 'authorized'
    # Check when get user role is success
    context 'when get user role is success' do
      before do
        get '/get_user_role', nil, 'HTTP_AUTHORIZATION' => session_token
      end
      # Call api success
      include_examples 'success_api'
    end

    # When get user role fail
    context 'when get user role is fail' do
      # Get user info is failure because of missing authorization
      context 'missing Authorization when get user role' do
        before do
          get '/get_user_role'
        end
        include_examples 'unauthorized'
      end
    end
  end

  # Describe: These unit test are using for api '/update_switch_view'
  describe '/update_switch_view' do
    context 'when update switch view success' do
      # Check when update switch view is success. In case value = 0
      context 'when update switch view success 1' do
        include_context 'authorized'
        data = {
          value: 0,
        }
        before do
          post '/update_switch_view', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api success
        include_examples 'success_api'
        it 'should return msg success' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Success')
        end
      end

      # Check when update switch view is success. In case value = 1
      context 'when update switch view success 2' do
        include_context 'authorized'
        data = {
          value: 1,
        }
        before do
          post '/update_switch_view', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api success
        include_examples 'success_api'
        it 'should return msg success' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Success')
        end
      end

      # Check when update switch view is success. In case value = blank
      context 'when update switch view success 3' do
        include_context 'generate_authorized', 'switchViewBlank4'
        data = {
          value: 1,
        }
        before do
          post '/update_switch_view', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api success
        include_examples 'success_api'
        it 'should return msg success' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Success')
        end
      end
    end

    # When update switch view is fail
    context 'when update switch view fail' do
      # Update switch view is failure because of missing authorization
      context 'missing Authorization when update switch view' do
        include_context 'authorized'
        before do
          post '/update_switch_view'
        end
        include_examples 'unauthorized'
        # Return msg Access denied because of missing authorization
        it 'should return msg access denied' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Access denied')
        end
      end

      # Update switch view is failure because of value is incorrect (Value not 0 or 1)
      context 'update switch view when value is incorrect' do
        include_context 'authorized'
        data = {
          value: 2,
        }
        before do
          post '/update_switch_view', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api fail because of value is incorrect
        include_examples 'failure_api'
        it 'should return msg update failed' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Update failed')
        end
      end

      # Update switch view is failure because of missing param value
      context 'update switch view when missing param value in data' do
        include_context 'authorized'
        data = {}
        before do
          post '/update_switch_view', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api fail because of missing param
        include_examples 'failure_api'
        # Return message: missing param
        it 'should return msg missing value' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Missing params: [:value]')
        end
      end

      # Update switch view is failure because of value is incorrect (Value is not number character)
      context 'update switch view when value is incorrect' do
        include_context 'authorized'
        data = {
          value: 'a',
        }
        before do
          post '/update_switch_view', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api fail because of value is incorrect
        include_examples 'failure_api'
        # Return message: something when wrong
        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Update failed')
        end
      end

      # Update switch view is failure because of value is blank
      context 'update switch view when value is blank' do
        include_context 'authorized'
        data = {
          value: '',
        }
        before do
          post '/update_switch_view', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api fail because of value is incorrect
        include_examples 'failure_api'
        # Return message: something when wrong
        it 'should return error message' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Missing params: [:value]')
        end
      end
    end
  end

  # Describe: These unit test are using for api '/session_info'
  describe '/session_info' do
    include_context 'authorized'
    # Check when get session info is success
    context 'when get session info success' do
      before do
        get '/session_info', nil, 'HTTP_AUTHORIZATION' => session_token
      end
      # Call api success
      include_examples 'success_api'
    end

    # When get session info fail
    context 'when get session info is fail' do
      # Get user info is failure because of missing authorization
      context 'missing Authorization when get session info' do
        before do
          get '/session_info'
        end
        include_examples 'unauthorized'
      end
    end
  end

  # Describe: These unit test are using for api '/reset_password'
  describe '/reset_password' do
    context 'reset password failure' do
      context 'reset password missing param' do
        data = {}
        before do
          post '/reset_password', data.to_json
        end
        # Call api success
        include_examples 'failure_api'
        # Return msg missing param
        it 'should return msg missing param' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Missing params: [:username]')
        end
      end

      context 'reset password missing param network inside' do
        data = {}
        before do
          SystemParamValue.where(system_param_id: 60).update(
            value: '127.0.0.0',
          )
          SystemParamValue.where(system_param_id: 61).update(
            value: '127.0.0.255',
          )
          post '/reset_password', data.to_json
          SystemParamValue.where(system_param_id: 60).update(
            value: '10.0.1.0',
          )
          SystemParamValue.where(system_param_id: 61).update(
            value: '10.0.4.255',
          )
        end
        # Call api success
        include_examples 'failure_api'
        # Return msg missing param
        it 'should return msg missing param' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Missing params: [:username]')
        end
      end

      context 'reset password username not exist' do
        data = {
          # This username is not exist
          username: 'UserIsNotExist',
        }
        before do
          post '/reset_password', data.to_json
        end
        # Call api success
        include_examples 'failure_api'
        # Because of username is not exist, then return ERR_COM_0001
        it 'should return ERR_COM_0001' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0001')
        end
      end

      context 'reset password username inside and not exist' do
        data = {
          # This username is not exist
          username: 'UserIsNotExist',
        }
        before do
          SystemParamValue.where(system_param_id: 60).update(
            value: '127.0.0.0',
          )
          SystemParamValue.where(system_param_id: 61).update(
            value: '127.0.0.255',
          )
          post '/reset_password', data.to_json
          SystemParamValue.where(system_param_id: 60).update(
            value: '10.0.1.0',
          )
          SystemParamValue.where(system_param_id: 61).update(
            value: '10.0.4.255',
          )
        end
        # Call api success
        include_examples 'failure_api'
        # Because of username is not exist, then return ERR_COM_0001
        it 'should return ERR_COM_0001' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0001')
        end
      end

      context 'reset password username not exist' do
        # User is blank
        data = { username: '' }
        before do
          post '/reset_password', data.to_json
        end
        # Call api success
        include_examples 'failure_api'
        it 'should return missing params' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Missing params: [:username]')
        end
      end

      context 'reset password username is nil' do
        # User is blank
        data = { username: nil }
        before do
          post '/reset_password', data.to_json
        end
        # Call api success
        include_examples 'failure_api'
        it 'should return sth when wrong' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Missing params: [:username]')
        end
      end

      # Time is expired
      context 'reset password username has expire' do
        data = {
          username: 'UserHasExpire',
        }
        before do
          post '/reset_password', data.to_json
        end
        # Call api success
        include_examples 'failure_api'
        # Because of time is expired , then return ERR_COM_0001
        it 'should return ERR_COM_0001' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0001')
        end
      end
    end

    context 'reset password success' do
      data = {
        # This username is exist. Only using for test reset password
        username: 'testuserresetpass',
      }
      before do
        post '/reset_password', data.to_json
      end
      # Call api success
      include_examples 'success_api'
    end

    context 'reset password success user inside' do
      data = {
        # This username is exist. Only using for test reset password
        username: 'testuserresetpass',
      }
      before do
        SystemParamValue.where(system_param_id: 60).update(
          value: '127.0.0.0',
        )
        SystemParamValue.where(system_param_id: 61).update(
          value: '127.0.0.255',
        )
        post '/reset_password', data.to_json
        SystemParamValue.where(system_param_id: 60).update(
          value: '10.0.1.0',
        )
        SystemParamValue.where(system_param_id: 61).update(
          value: '10.0.4.255',
        )
      end
      # Call api success
      include_examples 'success_api'
    end

    context 'reset pass when user not inside and network inside' do
      before do
        # Set network inside
        SystemParamValue.where(system_param_id: 60).update(
          value: '127.0.0.0',
        )
        SystemParamValue.where(system_param_id: 61).update(
          value: '127.0.0.255',
        )
        data = { username: 'userInside1', password: 'userInside123@' }
        post '/reset_password', data.to_json
        SystemParamValue.where(system_param_id: 60).update(
          value: '10.0.1.0',
        )
        SystemParamValue.where(system_param_id: 61).update(
          value: '10.0.4.255',
        )
      end
      include_examples 'failure_api'
      it 'should return error message' do
        response = JSON.parse(last_response.body)
        expect(response['message']).to eq('ERR_COM_0002')
      end
    end
  end

  # Describe: These unit test are using for api '/change_password'
  describe '/change_password' do
    include_context 'generate_authorized', 'testuserchangepass'
    context 'change password success' do
      before do
        permit_previous_password = system_param_value_sorted('permit_previous_password')
        permit_previous_password.first.update value: 'TRUE'
        @data = {
          old_pass: 'Hoilamchi1@',
          new_pass: 'Hoilamchi1@',
          retype_pass: 'Hoilamchi1@',
        }
      end
      context 'when password_ttl > 0' do
        before do
          current_user.user_role.update(password_ttl: 10)
          post '/change_password', @data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'success_api'

        it 'should update db' do
          check_updated = current_user.user_auth.password_encrypt == @data[:new_pass]
          expect(check_updated).to eq(true)
        end
        it 'password_expire should be valid' do
          check = current_user.user_role.password_expire.to_i > Time.now.to_i
          expect(check).to eq(true)
        end
      end
      context 'when password_ttl <= 0' do
        before do
          current_user.user_role.update(password_ttl: 0)
          post '/change_password', @data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        include_examples 'success_api'

        it 'should update db' do
          check_updated = current_user.user_auth.password_encrypt == @data[:new_pass]
          expect(check_updated).to eq(true)
        end
      end
    end

    context 'change password failure' do
      context 'missing authorization when change pass' do
        data = {
          old_pass: 'Testuser123@',
          new_pass: 'Hoilamchi1@',
          retype_pass: 'Hoilamchi1@',
        }
        before do
          post '/change_password', data.to_json
        end
        include_examples 'unauthorized'
      end

      context 'no param when change pass' do
        before do
          post '/change_password', nil, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api fail because of no param when change password
        include_examples 'failure_api'
      end

      context 'missing param when change pass 1' do
        data = {
          # old_pass: 'Testuser123@',
          new_pass: 'Hoilamchi1@',
          retype_pass: 'Hoilamchi1@',
        }
        before do
          post '/change_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api fail because of no param when change password
        include_examples 'failure_api'
      end

      context 'missing param when change pass 2' do
        data = {
          old_pass: 'Testuser123@',
          # new_pass: 'Hoilamchi1@',
          retype_pass: 'Hoilamchi1@',
        }
        before do
          post '/change_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api fail because of no param when change password
        include_examples 'failure_api'
      end

      context 'missing param when change pass 3' do
        data = {
          old_pass: 'Testuser123@',
          new_pass: 'Hoilamchi1@',
          # retype_pass: 'Hoilamchi1@',
        }
        before do
          post '/change_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api fail because of no param when change password
        include_examples 'failure_api'
      end

      context 'matching with current pass' do
        # Prepare data to test. In this unit test, password is not valid because of old password do not matching with current password
        before do
          permit_previous_password = system_param_value_sorted('permit_previous_password')
          permit_previous_password.first.update value: 'FALSE'
          data = {}
          data[:new_pass] = 'Hoilamchi1@'
          data[:retype_pass] = 'Hoilamchi1@'
          data[:old_pass] = 'Hoilamchi1@'
          post '/change_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0004' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0004')
        end
      end

      context 'not matching with retype pass' do
        # Prepare data to test. In this unit test, password is not valid because of old password do not matching with current password
        before do
          data = {}
          data[:new_pass] = 'Abcde12@'
          data[:retype_pass] = 'Abcde12345@'
          data[:old_pass] = 'Hoilamchi1@'
          post '/change_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0005' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0005')
        end
      end

      context 'not current pass' do
        # Prepare data to test. In this unit test, password is not valid because of old password do not matching with current password
        before do
          data = {}
          data[:new_pass] = 'Abcde123@='
          data[:retype_pass] = 'Abcde123@='
          data[:old_pass] = 'Testuser@123'
          post '/change_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0011' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0011')
        end
      end

      context 'size length' do
        # Prepare data to test. In this unit test, password is not valid because of password.length < 8
        before do
          data = {}
          password_level = system_param_value_sorted('password_level').first.value.to_i
          data[:old_pass] = 'Hoilamchi1@'
          data[:new_pass] = password_level.positive? ? generate_random_str(password_level - 1) : 1
          data[:retype_pass] = data[:new_pass]
          post '/change_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0003' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0003')
        end
      end

      context 'contain only uppercase' do
        # Prepare data to test. In this unit test, password is not valid because of new pass contain only uppercase
        before do
          data = {}
          data[:old_pass] = 'Hoilamchi1@'
          data[:new_pass] = 'ABCDEFGH'
          data[:retype_pass] = 'ABCDEFGH'
          post '/change_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0008' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0008')
        end
      end

      # check_valid_password is failure because of new password contain only lowercase
      # Then return error message: ERR_COM_0008
      context 'contain only lowercase' do
        # Prepare data to test. In this unit test, password is not valid because of new pass contain only lowercase
        before do
          data = {}
          data[:old_pass] = 'Hoilamchi1@'
          data[:new_pass] = 'abcdefgh'
          data[:retype_pass] = 'abcdefgh'
          post '/change_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0008' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0008')
        end
      end

      # check_valid_password is failure because of new password do not contain number character
      # Then return error message: ERR_COM_0009
      context 'not contain number character' do
        # Prepare data to test. In this unit test, password is not valid because of new pass not contain number character
        before do
          data = {}
          data[:new_pass] = 'Abcdefgh'
          data[:retype_pass] = 'Abcdefgh'
          data[:old_pass] = 'Hoilamchi1@'
          post '/change_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0009' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0009')
        end
      end

      # check_valid_password is failure because of new password do not contain special character
      # Then return error message: ERR_COM_0010
      context 'not contain special character' do
        # Prepare data to test. In this unit test, password is not valid because of new pass not contain special chacter
        before do
          data = {}
          data[:new_pass] = 'Abcde123'
          data[:retype_pass] = 'Abcde123'
          data[:old_pass] = 'Hoilamchi1@'
          post '/change_password', data.to_json, 'HTTP_AUTHORIZATION' => session_token
        end

        # Call api success
        include_examples 'success_api'
        # Response return include 'message' => To check for message
        include_examples 'common_response'

        it 'should return ERR_COM_0010' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('ERR_COM_0010')
        end
      end
    end
  end

  # Describe: These unit test are using for api '/list_approval_file'
  describe '/list_approval_file' do
    include_context 'generate_authorized', 'tonydo1'
    # Check when get list approval file is success
    context 'when get list approval file success' do
      before do
        get '/list_approval_file', nil, 'HTTP_AUTHORIZATION' => session_token
      end
      # Call api success
      include_examples 'success_api'
    end

    # Check when get list approval file is success
    context 'when get list approval file success 1' do
      before do
        get '/list_approval_file?locale=ja', nil, 'HTTP_AUTHORIZATION' => session_token
      end
      # Call api success
      include_examples 'success_api'
    end

    # When get list approval file fail
    context 'when get session info is fail' do
      # Get list approval file is failure because of missing authorization
      context 'missing Authorization when get list_approval_file' do
        before do
          get '/list_approval_file'
        end
        include_examples 'unauthorized'
      end
    end
  end

  # Describe: These unit test are using for api '/file_history_user'
  describe '/file_history_user' do
    include_context 'generate_authorized', 'test123'
    # Check when get file history of user is success
    context 'when get file history of user is success' do
      before do
        get '/file_history_user', nil, 'HTTP_AUTHORIZATION' => session_token
      end
      # Call api success
      include_examples 'success_api'
    end

    # Check when get file history of user is success
    context 'when get file history of user is success 2' do
      before do
        get '/file_history_user?locale=ja', nil, 'HTTP_AUTHORIZATION' => session_token
      end
      # Call api success
      include_examples 'success_api'
    end

    # When get file history of user fail
    context 'when get file history of user is fail' do
      # Get list approval file is failure because of missing authorization
      context 'missing Authorization when get file history of user' do
        before do
          get '/file_history_user'
        end
        include_examples 'unauthorized'
      end
    end
  end

  # Describe: These unit test are using for api '/file_of_user'
  describe '/file_of_user' do
    include_context 'authorized'
    context 'Get file of user success' do
      context 'Get file of user with action upload' do
        before do
          get '/file_of_user?action=upload', nil, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api fail because of invalid param
        include_examples 'success_api'
        # Return message: Success
        it 'should return msg Success' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Success')
        end
      end

      context 'Get file of user with action upload' do
        before do
          get '/file_of_user?action=download', nil, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api fail because of invalid param
        include_examples 'success_api'
        # Return message: Success
        it 'should return msg Success' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Success')
        end
      end
    end

    context 'Get file of user failure' do
      context 'Get file of user missing Authorization 1' do
        before do
          get '/file_of_user?action=download'
        end
        include_examples 'unauthorized'
        # Return message: Access denied because of missing authorization
        it 'should return msg Access denied' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Access denied')
        end
      end

      context 'Get file of user missing Authorization 2' do
        before do
          get '/file_of_user?action=upload'
        end
        include_examples 'unauthorized'
        # Return message: Access denied because of missing authorization
        it 'should return msg Access denied' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Access denied')
        end
      end

      # In this unit test: data is invalid and missing authorization
      context 'Get file of user missing Authorization 3' do
        before do
          get '/file_of_user?action=notavalidparam'
        end
        include_examples 'unauthorized'
        # Return message: Access denied because of missing authorization
        it 'should return msg Access denied' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Access denied')
        end
      end

      context 'Get file of user missing param' do
        before do
          get '/file_of_user', nil, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api fail because of missing param
        include_examples 'failure_api'
        # Return message: missing param because of missing param
        it 'should return msg missing params' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Missing params: [:action]')
        end
      end

      context 'Get file of user invalid param' do
        before do
          get '/file_of_user?action=notavalidparam', nil, 'HTTP_AUTHORIZATION' => session_token
        end
        # Call api fail because of invalid param
        include_examples 'failure_api'
        # Return message: invalid_params
        it 'should return msg Invalid params' do
          response = JSON.parse(last_response.body)
          expect(response['message']).to eq('Invalid params')
        end
      end
    end
  end

  # Describe: These unit test are using for api '/logout'
  describe '/logout' do
    include_context 'authorized'
    context 'logout success' do
      before do
        post '/logout', nil, 'HTTP_AUTHORIZATION' => session_token
      end
      include_examples 'success_api'
    end

    context 'logout failure' do
      before do
        post '/logout'
      end
      include_examples 'unauthorized'
      it 'should return msg Access denied' do
        response = JSON.parse(last_response.body)
        expect(response['message']).to eq('Access denied')
      end
    end
  end

  # Describe: These unit test are using for api '/can_upload'
  describe '/can_upload' do
    include_context 'authorized'
    context 'can upload success 1' do
      before do
        get '/can_upload', nil, 'HTTP_AUTHORIZATION' => session_token
      end
      include_examples 'success_api'
      # Return message: Success
      it 'should return msg success' do
        response = JSON.parse(last_response.body)
        expect(response['message']).to eq('Success')
      end
    end

    # can_upload success in case user has request
    context 'can upload success 1' do
      include_context 'generate_authorized', 'test123'
      before do
        get '/can_upload', nil, 'HTTP_AUTHORIZATION' => session_token
      end
      include_examples 'success_api'
      # Return message: Success
      it 'should return msg success' do
        response = JSON.parse(last_response.body)
        expect(response['message']).to eq('Success')
      end
    end

    context 'can upload failure' do
      before do
        get '/can_upload'
      end
      include_examples 'unauthorized'
      it 'should return msg access denied' do
        response = JSON.parse(last_response.body)
        expect(response['message']).to eq('Access denied')
      end
    end

    context 'can upload failure' do
      before do
        SystemParamValue.where(system_param_id: 68).update(
          value: 'FALSE',
        )
        get '/can_upload', nil, 'HTTP_AUTHORIZATION' => session_token
        SystemParamValue.where(system_param_id: 68).update(
          value: 'TRUE',
        )
      end
      include_examples 'success_api'
      it 'should return error msg' do
        response = JSON.parse(last_response.body)
        expect(response['message']).to eq('ERR_MEM_0019')
      end
    end
  end
end
