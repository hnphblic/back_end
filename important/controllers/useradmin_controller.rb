# frozen_string_literal: true

# Control User action
class AdminController < ApplicationController
  configure do
    set :no_auth_needs, %w[
      /login /sign_up /destroy
      /reset_password
    ]
  end
  before do
    unless settings.no_auth_needs.include?(env['PATH_INFO']) || authorized_admin?
      access_denied
    end
    convert_params
    # Using to logging start actions
  end

  # Using to login
  # Input: password, username
  # Output: jwt
  post '/login', needs: %i[username password] do
    begin
      process_login(params)
      rescue StandardError => e
        render_rescue(e)
        result = helper_render_message(
          400,
          I18n.t('common.errors.something_when_wrong'),
        )
        halt result[:status], result[:response].to_json
    end
  end

  # Using to check valid new_password
  # Input: new_pass, retype_pass
  # Process: Check valid of password depend system param
  post '/check_valid_password', needs: %i[new_pass retype_pass old_pass] do
    begin
      check_valid_password(params)
      result = helper_render_message(
        200,
        I18n.t('admin_controller.success.valid_password'),
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

  # Using to change password
  # Input: new_pass, retype_pass
  # Process: Check valid of password depend system param
  #          Save new password if new_password valid
  post '/change_password', needs: %i[old_pass new_pass retype_pass] do
    begin
      check_valid_password(params)
      admin = @current_admin
      admin_role = @current_admin.admin_role
      admin.update(password_encrypt: params[:new_pass])
      if admin_role.password_ttl.positive?
        admin_role.update(password_expire: Time.now + admin_role.password_ttl.days)
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

  # Using when logout system
  # Delete value of user's token in user_session_info
  post '/logout' do
    begin
      token = @current_admin.user_session_info.where(name: 'session_token_admin').first
      token.update(value: '')
      result = helper_render_message(
        200,
        I18n.t('success.common.congrate'),
      )
    rescue StandardError => e
      render_rescue(e)
      result = helper_render_message(
        400,
        I18n.t('erorrs.common.something_when_wrong'),
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
      admin = AdminInfo.where(username: params[:username]).first
      if admin.blank?
        result = helper_render_message(
          400,
          'ERR_COM_0001',
        )
        halt result[:status], result[:response].to_json
      end
      password_level = system_param_value_sorted('password_level').first
      new_pass = generate_random password_level.value.to_i
      auth.update(password: new_pass)
      data = {
        new_pass: new_pass,
        email: admin.email,
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

  # Using to get admin info
  # Output: admin_info
  get '/admin_info' do
    begin
      # This network is rotated because:
      # This variable using to select these file was uploaded in opposite with current user network
      data = {
        email: @current_admin.email,
        username: @current_admin.username,
      }
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
  post '/update_admin', allows: %i[email username] do
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
      @current_admin.email = params[:email] if params[:email].present?
      @current_admin.username = params[:username] if params[:username].present?
      if @current_admin.save
        result = helper_render_message(
          200,
          I18n.t('common.success.congrate'),
        )
      else
        result = helper_render_message(
          400,
          I18n.t('admin_controller.errors.update_fail'),
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
  get '/get_admin_role' do
    begin
      admin_role = @current_admin.admin_role
      result = helper_render_message(
        200,
        I18n.t('common.success.congrate'),
        role_info: {
          is_lock: admin_role.is_lock,
          ip_access: admin_role.ip_access,
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
      admin = AdminInfo.new(
        email: params[:email],
        username: params[:username],
        password: encrypt_sha_data(params[:password]),
        create_date: Time.now,
        is_deleted: false,
      )

      unless admin.save
        result = helper_render_message(
          400,
          I18n.t('admin_controller.errors.cannot_create_admin'),
          admin.errors.messages,
        )
        halt result[:status], result[:response].to_json
      end
      # Create rolelist
      role_list = AdminRole.new(
        admin_id: admin.id,
        is_lock: false,
      )
      unless role_list.save
        admin.destroy
        result = helper_render_message(
          400,
          I18n.t('admin_controller.errors.cannot_create_admin'),
          auth.errors.messages,
        )
        halt result[:status], result[:response].to_json
      end

      session_info = UserSessionInfo.new(
        user_id: admin.id,
        name: 'session_token_admin',
        value: '',
      )
      unless session_info.save
        admin.destroy
        role_list.destroy
        result = helper_render_message(
          400,
          I18n.t('admin_controller.errors.cannot_create_admin'),
          auth.errors.messages,
        )
        halt result[:status], result[:response].to_json
      end
    rescue StandardError => e
      unless admin.nil?
        admin.destroy
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
      I18n.t('admin_controller.success.create_account'),
    )
    halt result[:status], result[:response].to_json
  end

  # DELETE an uer
  post '/destroy' do
    begin
      admin = Admin.where(email: params[:email]).first
      admin.destroy
    rescue
      result = helper_render_message(
        400,
        I18n.t('admin_controller.errors.cannot_delete_admin'),
      )
      halt result[:status], result[:response].to_json
    end
  end
  private

  # Solve logic, validate login action
  # Input: Prameter: params
  # Output: Void
  def process_login(params)
    # check admin present
    admin = AdminInfo.is_present.where(
      username: params[:username],
    ).first
    if admin.blank?
      result = helper_render_message(
        200,
        I18n.t('admin_controller.errors.admin_not_found'),
      )
      halt result[:status], result[:response].to_json
    end
    
    check_pasword(admin, params)
    check_role(admin)   
    token = admin.user_session_info.where(name: 'session_token_admin').first
    token.value = encrypt_sha_data(admin.username + Time.now.to_i.to_s)
    token.save
    admin.update last_login: Time.now
    
    data_admin = {
      id: admin.id,
      name: admin.username,
      session_token_admin: token.value
    }
    result = helper_render_message(
      200,
      I18n.t('common.success.congrate'),
      jwt: encrypt_jwt(data_admin),
    )
    halt result[:status], result[:response].to_json
  end

  # Using check password
  # Input: UserInfo: user, SystemParamValue: password
  # Output: void
  def check_pasword(admin, params) 
    if check_sha_data(admin.password, params[:password]) == false
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
  def check_role(admin)
    if admin.admin_role.is_lock
      result = helper_render_message(
        200,
        I18n.t('admin_controller.errors.is_lock'),
      )
      halt result[:status], result[:response].to_json
    end
    true
  end

  # Using login using local auth method
  # Input: UserInfo: user, SystemParamValue: sys_value
  # Output: void
  def check_use_local_auth(admin)
    check_role(admin)
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
    if @current_admin.password != params[:old_pass]
      result = helper_render_message(
        200,
        'ERR_COM_0011',
      )
      halt result[:status], result[:response].to_json
    end

    # Check new_pass and old_pass
    permit_previous_password = system_param_value_sorted('permit_previous_password')
    allow_match_previous_pass = permit_previous_password.first.value
    if !true?(allow_match_previous_pass) &&
       @current_admin.password == params[:new_pass]
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
