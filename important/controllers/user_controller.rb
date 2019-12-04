# frozen_string_literal: true

# Control User action
class UserController < ApplicationController
  configure do
    set :no_auth_needs, %w[
      /sign_up /destroy
      /reset_password /check_network
    ]
  end
  before do
    unless settings.no_auth_needs.include?(env['PATH_INFO']) || authorized?
      access_denied
    end
    convert_params
  end


  post '/check_valid_password', needs: %i[new_pass retype_pass old_pass] do
    begin
      check_valid_password(params)
      result = helper_render_message(
        200,
        I18n.t('user_controller.success.valid_password'),
      )
    rescue StandardError => e
      render_rescue(e)
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
      )
    end
    halt result[:status], result[:response].to_json
  end

 
  post '/change_password', needs: %i[old_pass new_pass retype_pass] do
    begin
      check_valid_password(params)
      user = @current_user
      auth = @current_user.user_auth
      user_role = @current_user.user_role
      user.update(password_encrypt: params[:new_pass])
      if user_role.password_ttl.positive?
        user_role.update(password_expire: Time.now + user_role.password_ttl.days)
      end
      result = helper_render_message(
        200,
        I18n.t('common.success.congrate'),
      )
    rescue StandardError => e
      render_rescue(e)
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
      )
    end
    halt result[:status], result[:response].to_json
  end

  # Using to reset password
  # Input: email, username
  # Output: Void
  # Reset password to a random string
  post '/reset_password', needs: %i[username] do
    begin
      network = check_inside(request.ip)
      user = UserInfo.where(username: params[:username]).first
     
      if user.blank?
        result = helper_render_message(
          400,
          'ERR_COM_0001',
        )
        halt result[:status], result[:response].to_json
      end
     
      password_level = system_param_value_sorted('password_level').first
      new_pass = generate_random password_level.value.to_i
      user.update(password: new_pass)
      data = {
        new_pass: new_pass,
        email: user.email,
      }
      send_email_reset_password(data)
    rescue StandardError => e
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
      )
      halt result[:status], result[:response].to_json
    end
  end

  # Using to get user info
  # Output: user_info: {
  #    :name, :email, :quota, :password_expire, :user_expire,
  #    :total_size, :capacity
  # }
  get '/user_info' do
    begin
      # This network is rotated because:
      # This variable using to select these file was uploaded in opposite with current user network
      is_inside = check_inside(request.ip)
      is_user = AssignApproval.where(user_id_approval: @current_user.id).blank?
      data = {
        name: @current_user.name,
        email: @current_user.email,
        quota: @current_user.user_role.quota,
        username_inside: @current_user.user_auth.username_inside,
        username_outside: @current_user.user_auth.username_outside,
        role: is_user ? 'User' : 'Approver',
      }
      if (@current_user.user_role.inside_local_auth && is_inside) ||
         (@current_user.user_role.outside_local_auth && !is_inside)
        data[:password_expire] = @current_user.user_role.password_expire || ''
        data[:user_expire] = @current_user.user_role.user_expire || ''
      end
      list_request_approval = Request.where(
        user_id_request: @current_user.id,
        status: [2, 4],
      ).pluck(:file_id)
      list_file_of_user = Files.is_present.where(id: list_request_approval).pluck(:size_byte)
      data[:total_size] = list_file_of_user.sum
      data[:capacity] = data[:quota].positive? ? ((data[:total_size].to_f / data[:quota]) * 100).round(2) : 0
      result = helper_render_message(
        200,
        I18n.t('common.success.congrate'),
        data,
      )
    rescue StandardError => e
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
      )
    end
    halt result[:status], result[:response].to_json
  end

  # Using to update user info
  # Input: some attributes allow to change
  # Output: void method, update attributes
  post '/update_user', allows: %i[email username] do
    begin
      if params[:email].present? &&
         !help_valid_email?(params[:email]) &&
         !check_max_lenght(params[:email], Constants::MaxLength::EMAIL_MAX_LENGTH)
        result = helper_render_message(
          400,
          I18n.t('common.errors.invalid_params') + ': email',
        )
        halt result[:status], result[:response].to_json
      end
      if params[:username].present? &&
         !check_max_lenght(params[:username], Constants::MaxLength::NAME_MAX_LENGTH)
        result = helper_render_message(
          400,
          I18n.t('common.errors.invalid_params') + ': username',
        )
        halt result[:status], result[:response].to_json
      end
      @current_user.email = params[:email] if params[:email].present?
      @current_user.username = params[:username] if params[:username].present?
      if @current_user.save
        result = helper_render_message(
          200,
          I18n.t('common.success.congrate'),
        )
      else
        result = helper_render_message(
          400,
          I18n.t('user_controller.errors.update_fail'),
        )
      end
    rescue StandardError => e
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
      )
    end
    halt result[:status], result[:response].to_json
  end

  # Using to get user role
  get '/get_user_role' do
    begin
      user_role = @current_user.user_role
      result = helper_render_message(
        200,
        I18n.t('common.success.congrate'),
        role_info: {
          percent: user_role.percent,
          agency: user_role.agency,
          money: user_role.money,
          is_lock: user_role.is_lock,
          ip_access: user_role.ip_access,
        },
      )
    rescue StandardError => e
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
      )
    end
    halt result[:status], result[:response].to_json
  end

  # # Using to sign_up
  # # Input: email, password, username
  post '/sign_up', needs: %i[email password username] do
    begin
      user = UserInfo.new(
        email: params[:email],
        username: params[:username],
        password: encrypt_sha_data(params[:password]),
        create_date: Time.now,
        is_deleted: false,
      )

      unless user.save
        result = helper_render_message(
          400,
          I18n.t('user_controller.errors.cannot_create_user'),
          user.errors.messages,
        )
        halt result[:status], result[:response].to_json
      end
      # Create rolelist
      role_list = UserRole.new(
        user_id: user.id,
        is_lock: false,
        money: params[:money] || 0.0,
        percent: params[:percent] || 0,
        agency: params[:agency] || 0,
      )
      unless role_list.save
        user.destroy
        result = helper_render_message(
          400,
          I18n.t('user_controller.errors.cannot_create_user'),
          auth.errors.messages,
        )
        halt result[:status], result[:response].to_json
      end

      session_info = UserSessionInfo.new(
        user_id: user.id,
        name: 'session_token',
        value: '',
      )
      unless session_info.save
        user.destroy
        role_list.destroy
        result = helper_render_message(
          400,
          I18n.t('user_controller.errors.cannot_create_user'),
          auth.errors.messages,
        )
        halt result[:status], result[:response].to_json
      end
    rescue StandardError => e
      unless user.nil?
        user.destroy
      end
     
      render_rescue e
      result = helper_render_message(
        400,
        I18n.t('common.errors.something_when_wrong'),
      )
      halt result[:status], result[:response].to_json
    end
    result = helper_render_message(
      200,
      I18n.t('user_controller.success.create_account'),
    )
    halt result[:status], result[:response].to_json
  end

  # DELETE an uer
  post '/destroy' do
    begin
      user = User.where(email: params[:email]).first
      user.destroy
    rescue
      result = helper_render_message(
        400,
        I18n.t('user_controller.errors.cannot_delete_user'),
      )
      halt result[:status], result[:response].to_json
    end
  end
  private

 

  # Using check password
  # Input: UserInfo: user, SystemParamValue: password
  # Output: void
  def check_pasword(user, params) 
    if check_sha_data(user.password, params[:password]) == false
      result = helper_render_message(
        200,
        I18n.t('user_controller.errors.password_failed'),
      )
      halt result[:status], result[:response].to_json
    end
    true
  end

  # Using check role, access permission of user
  # Input: UserInfo: user, SystemParamValue: sys_value
  # Output: void
  def check_role(user)
    if user.user_role.is_lock
      result = helper_render_message(
        200,
        I18n.t('user_controller.errors.is_lock'),
      )
      halt result[:status], result[:response].to_json
    end
    true
  end

  # Using login using local auth method
  # Input: UserInfo: user, SystemParamValue: sys_value
  # Output: void
  def check_use_local_auth(user)
    check_role(user)
  end
  

  # check_existed_expire_data method using to check:
  # Whether user exist or not
  # Whether user still have access permission
  # Check authentication method
  # Input: UserAuth: auth, String: email
  # Output: - Retunr error with message if invalid
  #         - UserInfo object if pass all validate
  def check_existed_expire_data(auth, network)
    user = UserInfo.where(id: auth.user_id).first
    if user.blank?
      result = helper_render_message(
        400,
        'ERR_COM_0001',
      )
      halt result[:status], result[:response].to_json
    end
    if (user.user_role.inside_local_auth && network) ||
       (user.user_role.outside_local_auth && !network)
      if user.user_role.user_expire.present? &&
         user.user_role.user_expire < Time.now
        result = helper_render_message(
          400,
          'ERR_COM_0001',
        )
        halt result[:status], result[:response].to_json
      end
    else
      result = helper_render_message(
        400,
        'ERR_COM_0002',
      )
      halt result[:status], result[:response].to_json
    end
    user
  end

  # Check validate password base on system params status
  # List conditions may be included:
  # 1. lenght_password >= system_param[:password_level] (return with error ERR_COM_0003 if failure )
  # 2. old_pass != user_auth.password_encrypt (return with error ERR_COM_0011 if failure )
  # 3. new_pass != old_pass (return with error ERR_COM_0004 if failure )
  # 4. new_pass included uppercase & downcase (return with error ERR_COM_0008 if failure )
  # 5. new_pass included digit (return with error ERR_COM_0009 if failure )
  # 6. new_pass included special character (return with error ERR_COM_0010 if failure )
  # 7. new_pass != retype_pass (return with error ERR_COM_0005 if failure )
  def check_valid_password(params)
    password_level = system_param_value_sorted('password_level').first.value
    if params[:new_pass].size < password_level.to_i
      result = helper_render_message(
        200,
        'ERR_COM_0003',
      )
      halt result[:status], result[:response].to_json
    end

    # old_pass != user_auth.password_encrypt
    if @current_user.user_auth.password_encrypt != params[:old_pass]
      result = helper_render_message(
        200,
        'ERR_COM_0011',
      )
      halt result[:status], result[:response].to_json
    end

    # Check new_pass and old_pass
    permit_previous_password = system_param_value_sorted('permit_previous_password')
    allow_match_previous_pass = permit_previous_password.first.value
    auth = @current_user.user_auth
    if !true?(allow_match_previous_pass) &&
       auth.password_encrypt == params[:new_pass]
      result = helper_render_message(
        200,
        'ERR_COM_0004',
      )
      halt result[:status], result[:response].to_json
    end

    # Check password has uppercase and downcase
    require_upper_down_case = system_param_value_sorted('require_uppercase_downcase').first
    if true?(require_upper_down_case.value) &&
       (params[:new_pass].scan(/[A-Z]/).blank? ||
       params[:new_pass].scan(/[a-z]/).blank?)
      result = helper_render_message(
        200,
        'ERR_COM_0008',
      )
      halt result[:status], result[:response].to_json
    end

    # Check password has at least a digit
    require_digit = system_param_value_sorted('require_digit').first
    if true?(require_digit.value) &&
       params[:new_pass].scan(/\d/).blank?
      result = helper_render_message(
        200,
        'ERR_COM_0009',
      )
      halt result[:status], result[:response].to_json
    end

    # Check password has special character
    require_special_character = system_param_value_sorted('require_special_character').first
    if true?(require_special_character.value) &&
       params[:new_pass].scan(/\W/).blank?
      result = helper_render_message(
        200,
        'ERR_COM_0010',
      )
      halt result[:status], result[:response].to_json
    end

    # Check diff new_pass and retype_pass
    if params[:new_pass] != params[:retype_pass]
      result = helper_render_message(
        200,
        'ERR_COM_0005',
      )
    end
    halt result[:status], result[:response].to_json if result.present?
  end

  def can_access; end
end
