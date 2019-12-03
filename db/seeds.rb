# frozen_string_literal: true

require 'pry'
# is_locked = User.where(username: 'is_locked').first
# user_expired = User.where(username: 'user_expired').first
# password_expired = User.where(username: 'password_expired').first
# # role_list = [
# #   {
# #     user_id: user.id,
# #     is_admin: false,
# #     is_lock: false,
# #     user_local_auth: 0,
# #     password_expire: Time.now - 30.days,
# #     user_expire: Time.now -30.days
# #   }
# # ]
# # binding.prys
# RoleList.create(
#   user_id: is_locked.id,
#   is_admin: false,
#   is_lock: true,
#   user_local_auth: 0,
#   password_expire: Time.now + 30.days,
#   user_expire: Time.now + 30.days
# )

# RoleList.create(
#   user_id: user_expired.id,
#   is_admin: false,
#   is_lock: false,
#   user_local_auth: 0,
#   password_expire: Time.now + 30.days,
#   user_expire: Time.now - 30.days
# )
# RoleList.create(
#   user_id: password_expired.id,
#   is_admin: false,
#   is_lock: false,
#   user_local_auth: 0,
#   password_expire: Time.now - 30.days,
#   user_expire: Time.now + 30.days
# )

# # role_list.each do |role|
# #   RoleList.create(role)
# # end

# Create System Params
#==begin
# # sys = SystemParams.create(name: 'action_expire_password', category: 0)
# # sys.system_param_values.create(sort_order: 0, value: '-1')
#==end

# Create Policy Approval data
#==begin
# PolicyApproval.create(system_id: 0)
# PolicyApproval.create(system_id: 1)
#==end

# # ==begin
# # Create Master Division
# MasterDivision.create(
#   division_kind_num: 1,
#   division_kind_name: 'ウイルスチェック',
#   division_value: 1,
#   division_name_ja: '処理中',
#   division_name_en: 'Processing'
# )
# MasterDivision.create(
#   division_kind_num: 1,
#   division_kind_name: 'ウイルスチェック',
#   division_value: 2,
#   division_name_ja: '有効',
#   division_name_en: 'Valid'
# )
# MasterDivision.create(
#   division_kind_num: 1,
#   division_kind_name: 'ウイルスチェック',
#   division_value: 3,
#   division_name_ja: '無効',
#   division_name_en: 'Invalid'
# )
# MasterDivision.create(
#   division_kind_num: 1,
#   division_kind_name: 'ウイルスチェック',
#   division_value: 4,
#   division_name_ja: 'スキップ',
#   division_name_en: 'Skip'
# )
# MasterDivision.create(
#   division_kind_num: 1,
#   division_kind_name: 'ウイルスチェック',
#   division_value: 5,
#   division_name_ja: '未チェック',
#   division_name_en: 'Unchecked',
# )
# MasterDivision.create(
#   division_kind_num: 2,
#   division_kind_name: '無害化',
#   division_value: 1,
#   division_name_ja: '処理中',
#   division_name_en: 'Processing'
# )
# MasterDivision.create(
#   division_kind_num: 2,
#   division_kind_name: '無害化',
#   division_value: 2,
#   division_name_ja: '無害化成功',
#   division_name_en: 'Success'
# )
# MasterDivision.create(
#   division_kind_num: 2,
#   division_kind_name: '無害化',
#   division_value: 3,
#   division_name_ja: '無害化失敗',
#   division_name_en: 'Failed'
# )
# MasterDivision.create(
#   division_kind_num: 2,
#   division_kind_name: '無害化',
#   division_value: 4,
#   division_name_ja: 'スキップ',
#   division_name_en: 'Skip'
# )
# MasterDivision.create(
#   division_kind_num: 2,
#   division_kind_name: '無害化',
#   division_value: 5,
#   division_name_ja: 'スキャンできません',
#   division_name_en: 'Unable to scan',
# )
# MasterDivision.create(
#   division_kind_num: 3,
#   division_kind_name: '承認却下',
#   division_value: 1,
#   division_name_ja: '承認待ち',
#   division_name_en: 'Pending'
# )
# MasterDivision.create(
#   division_kind_num: 3,
#   division_kind_name: '承認却下',
#   division_value: 2,
#   division_name_ja: '承認（許可）',
#   division_name_en: 'Authorization'
# )
# MasterDivision.create(
#   division_kind_num: 3,
#   division_kind_name: '承認却下',
#   division_value: 3,
#   division_name_ja: '否認',
#   division_name_en: 'Denial'
# )
# MasterDivision.create(
#   division_kind_num: 3,
#   division_kind_name: '承認却下',
#   division_value: 4,
#   division_name_ja: 'スキップ',
#   division_name_en: 'Skip'
# )

# MasterDivision.create(
#   division_kind_num: 4,
#   division_kind_name: 'アクション',
#   division_value: 1,
#   division_name_ja: 'アップロード',
#   division_name_en: 'Upload'
# )
# MasterDivision.create(
#   division_kind_num: 4,
#   division_kind_name: 'アクション',
#   division_value: 2,
#   division_name_ja: 'ダウンロード',
#   division_name_en: 'Download'
# )
# MasterDivision.create(
#   division_kind_num: 4,
#   division_kind_name: 'アクション',
#   division_value: 3,
#   division_name_ja: '削除',
#   division_name_en: 'Delete'
# )
# MasterDivision.create(
#   division_kind_num: 4,
#   division_kind_name: 'アクション',
#   division_value: 4,
#   division_name_ja: 'プレビュー',
#   division_name_en: 'Preview'
# )
# MasterDivision.create(
#   division_kind_num: 4,
#   division_kind_name: 'アクション',
#   division_value: 5,
#   division_name_ja: '承認待ち',
#   division_name_en: 'Pending'
# )
# MasterDivision.create(
#   division_kind_num: 4,
#   division_kind_name: 'アクション',
#   division_value: 6,
#   division_name_ja: '承認（許可）',
#   division_name_en: 'Authorization'
# )
# MasterDivision.create(
#   division_kind_num: 4,
#   division_kind_name: 'アクション',
#   division_value: 7,
#   division_name_ja: '否認',
#   division_name_en: 'Denial'
# )
# MasterDivision.create(
#   division_kind_num: 4,
#   division_kind_name: 'アクション',
#   division_value: 8,
#   division_name_ja: 'スキップ',
#   division_name_en: 'Skip'
# )
# MasterDivision.create(
#   division_kind_num: 4,
#   division_kind_name: 'アクション',
#   division_value: 9,
#   division_name_ja: '無害化(成功)',
#   division_name_en: 'Success'
# )
# MasterDivision.create(
#   division_kind_num: 4,
#   division_kind_name: 'アクション',
#   division_value: 10,
#   division_name_ja: '無害化(失敗)',
#   division_name_en: 'Failed'
# )

# # ==end

# # ==begin
# # Create data system param

# sys = SystemParam.create(name: 'user_logo_image', category: 0)
# sys.system_param_values.create(sort_order: 0, value: 'localhost')

# sys = SystemParam.create(name: 'user_logo_image_visible',category: 0)
# sys.system_param_values.create(sort_order: 0, value: 'TRUE')

# sys = SystemParam.create(name: 'title_network_local_ja',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '基幹系')

# sys = SystemParam.create(name: 'title_network_local_en',category: 0)
# sys.system_param_values.create(sort_order: 0, value: 'Backbone System')

# sys = SystemParam.create(name:'title_network_external_ja',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '情報系')

# sys = SystemParam.create(name: 'title_network_external_en',category: 0)
# sys.system_param_values.create(sort_order: 0, value: 'Information System')

# sys = SystemParam.create(name: 'color_network_local',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '#FF7C80')

# sys = SystemParam.create(name:'color_network_external',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '#3399FF')

# sys = SystemParam.create(name: 'qouta_file',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '2097152')

# sys = SystemParam.create(name: 'extention_file',category: 0)
# sys.system_param_values.create(sort_order: 0, value: 'zip,txt,doc, docx,xlsx,xls')

# sys = SystemParam.create(name: 'email_conf_user_add_ja',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '【ユーザーアカウント追加通知】\nMAIL_TO様\n\nあなたのアカウントをSYSTEM_NAMEに登録しました。')

# sys = SystemParam.create(name: 'email_conf_user_add_en',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '')

# sys = SystemParam.create(name: 'email_conf_user_edit_ja',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '【ユーザーアカウント変更通知】\nMAIL_TO様\n\nSYSTEM_NAMEのあなたのアカウントを変更しました。')

# sys = SystemParam.create(name: 'email_conf_user_edit_en',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '')

# sys = SystemParam.create(name: 'email_conf_password_ja',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '【新パスワード通知】\nMAIL_TO様\n\nSYSTEM_NAMEのパスワードを（再）設定しました。\n新パスワードでログインしてください。\nこのメールに関して不明なことがあれば、[問い合わせ先]のアドレスにメールで\n問い合わせてください。')

# sys = SystemParam.create(name: 'email_conf_password_en',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '')

# sys = SystemParam.create(name: 'email_conf_daily_report_ja', category: 0)
# sys.system_param_values.create(sort_order: 0, value: 'SYSTEM_NAMEの日報(DATE)\nMAIL_TO様\n\nDATEのSYSTEM_NAMEの状況をお知らせします。\n\n')

# sys = SystemParam.create(name: 'email_conf_daily_report_en',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '')

# sys = SystemParam.create(name: 'email_conf_user_report_ja', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '【ユーザーアカウント(USER_ID)追加通知】\nMAIL_TO様\n\nSYSTEM_NAMEのアカウント(USER_ID)を追加しました。')

# sys = SystemParam.create(name: 'email_conf_user_report_en', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '')

# sys = SystemParam.create(name: 'email_conf_upload_ja',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '【アップロード通知】FILE_NAMEがアップロードされました\nMAIL_TO様\n\nSYSTEM_NAMEに次のファイルがアップロードされたのでお知らせします。\n\nSYSTEM_NAMEにアクセスするにはユーザー登録が必要です。\nユーザー登録を希望する場合やパスワードを忘れた場合は、\n[問い合わせ先]のアドレスにメールで問い合わせてください。')

# sys = SystemParam.create(name: 'email_conf_upload_en',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '')

# sys = SystemParam.create(name: 'email_conf_download_ja',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '【ダウンロード通知】FILE_NAMEがダウンロードされました\nMAIL_TO様\n\nあなたがSYSTEM_NAMEにアップロードしたファイルがダウンロードされました。\nこのメールに関して不明なことがあれば、[問い合わせ先]のアドレスにメールで\n問い合わせてください。\nダウンロードの詳細は、以下です。')

# sys = SystemParam.create(name: 'email_conf_download_en', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '')

# sys = SystemParam.create(name: 'email_conf_file_change_ja', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '【変更通知】FILE_NAMEのファイル情報が変更されました\nMAIL_TO様\n\nあなたがSYSTEM_NAMEにアップロードした次のファイルの情報が変更されました。\nこのメールに関して不明なことがあれば、[問い合わせ先]のアドレスにメールで\n問い合わせてください。\n変更の詳細は、以下です。')

# sys = SystemParam.create(name: 'email_conf_file_change_en', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '')

# sys = SystemParam.create(name: 'email_conf_delete_ja', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '【削除通知】FILE_NAMEが削除されました\nMAIL_TO様\n\nあなたがSYSTEM_NAMEにアップロードした下記のファイルが削除されました。\nこのメールに関して不明なことがあれば、[問い合わせ先]のアドレスにメールで\n問い合わせてください。\n削除の詳細は、以下です。')

# sys = SystemParam.create(name: 'email_conf_delete_en', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '')

# sys = SystemParam.create(name: 'email_conf_pre_delete_ja', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '【削除予告通知】FILE_NAMEが削除されます。\nMAIL_TO様\n\nあなたがSYSTEM_NAMEにアップロードした下記のファイルが削除されます。\nこのメールに関して不明なことがあれば、[問い合わせ先]のアドレスにメールで\n問い合わせてください。\n削除の詳細は、以下です。')

# sys = SystemParam.create(name: 'email_conf_pre_delete_en', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '')

# sys = SystemParam.create(name: 'email_conf_sanitize_ok_ja', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '【無害化処理成功通知メール】\nMAIL_TO様\n\n下記のFILE_NAMEは、無害化処理成功されました。')

# sys = SystemParam.create(name: 'email_conf_sanitize_ok_en',category: 0)
# sys.system_param_values.create(sort_order: 0, value: '')

# sys = SystemParam.create(name: 'email_conf_sanitize_ng_ja', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '【無害化処理失敗通知メール】\nMAIL_TO様\n\n下記のFILE_NAMEは、無害化処理失敗されました。')

# sys = SystemParam.create(name: 'email_conf_sanitize_ng_en', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '')

# sys = SystemParam.create(name: 'email_conf_want_approve_ja', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '【承認要求メール】\nMAIL_TO様\n\n承認要求が送信されました。\n下記の[承認URL]から承認作業を行うことができます。')

# sys = SystemParam.create(name: 'email_conf_want_approve_en', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '')

# sys = SystemParam.create(name: 'email_conf_approve_ok_ja', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '【承認通知メール】\nMAIL_TO様\n\n下記のFILE_NAMEは、承認されました。')

# sys = SystemParam.create(name: 'email_conf_approve_ok_en', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '')

# sys = SystemParam.create(name: 'email_conf_approve_ng_ja', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '【否認通知メール】\nMAIL_TO様\n\n下記のFILE_NAMEは、否認されました。')

# sys = SystemParam.create(name: 'email_conf_approve_ng_en', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '')

# sys = SystemParam.create(name: 'disp_pwchange_link', category: 0)
# sys.system_param_values.create(sort_order: 0, value: 'TRUE')

# sys = SystemParam.create(name: 'display_lang_change', category: 0)
# sys.system_param_values.create(sort_order: 0, value: 'TRUE')

# sys = SystemParam.create(name: 'useAutogenPassword', category: 0)
# sys.system_param_values.create(sort_order: 0, value: 'TRUE')

# sys = SystemParam.create(name: 'passwordLevel', category: 0)
# sys.system_param_values.create(sort_order: 0, value: '8')

# sys = SystemParam.create(name: 'disp_admin_contact', category: 0)
# sys.system_param_values.create(sort_order: 0, value: 'TRUE')
# # ==end

# Create file
# u1 = UserInfo.first
# u2 = UserInfo.last
# file_1 = Files.create(
#   user_id_upload: u1.id,
#   name: 'test',
#   size_byte: 100,
#   extension: 'txt',
# )
# file_2 = Files.create(
#   user_id_upload: u1.id,
#   name: 'test1',
#   size_byte: 200,
#   extension: 'png',
# )

# Request.create(
#   file_id: file_1.id,
#   user_id_request: u1.id,
#   user_id_approval: u2.id,
#   system_id_request: 1,
#   system_id_approval: 0,
#   comment_request: 'Upload tu mang noi bo',
#   request_date:  Time.now,
#   approval_date: Time.now,
#   comment_approval: 'OK',
#   status: 2,
# )
# # binding.pry

# Request.create(
#   file_id: file_2.id,
#   user_id_request: u1.id,
#   request_date:  Time.now,
#   system_id_request: 0,
#   system_id_approval: 1,
#   comment_request: 'Upload tu mang noi bo',
#   status: 4,
# )

# service_1 = Service.create( name: 'BitDefender')
# service_1 = Service.create( name: 'Votiro')
# service_1 = Service.create( name: 'Opswat')
# service_1 = Service.create( name: 'Shieldex')

# AssignApproval.create(user_id_request: u1.id, user_id_approval: u2.id)
# AssignApproval.create(user_id_request: u2.id, user_id_approval: u1.id)

# Service.all.each_with_index do |s, index|
#   ServicePolicy.create(
#     service_id: s.id,
#     system_id: 0,
#     status: true,
#     priority: index,
#   )
#   ServicePolicy.create(
#     service_id: s.id,
#     system_id: 1,
#     status: true,
#     priority: index,
#   )
# end

# ApprovalPolicy.create(
#   system_id: 0,
#   status: false,
#   require_download: false,
#   require_preview: false
# )
# ApprovalPolicy.create(
#   system_id: 1,
#   status: false,
#   require_download: false,
#   require_preview: false
# )

# u = UserInfo.first
# (1..10).each do |i|
#   f = Files.create(
#     user_id_upload: u.id,
#     name: "file_#{i}",
#     size_byte: i * 100,
#     extension: 'csv',
#   )
#   Request.create(
#     file_id: f.id,
#     user_id_request: u.id,
#     system_id_request: 0,
#     comment_request: 'OK',
#     status: 1,
#     request_date: Time.now
#   )
#   FileHistory.create(
#     user_id: u.id,
#     file_id: f.id,
#     action: 1,
#     system_id: 0,
#     timestapm: Time.now,
#   )
#   Service.all.each do |s|
#     f.file_service.create(
#       service_id: s.id,
#       value: 1,
#     )
#   end
# end

# AuthServer.create(
#   hostname: '10.0.3.249',
#   port: 389,
#   username: 'Administrator',
#   password: 'luvina@123',
#   is_local: true,
#   is_external: false,
#   status: true,
#   create_date: Time.now,
# )

# AuthServer.create(
#   hostname: '10.0.3.230',
#   port: 389,
#   username: 'Administrator',
#   password: 'luvina@123',
#   is_local: false,
#   is_external: true,
#   status: false,
#   create_date: Time.now,
# )

# s = SystemParam.create(
#   name: 'email_notification',
#   category: 0,
# )
# s.system_param_values.create(
#   value: 'FALSE',
#   sort_order: 0
# )

# s = SystemParam.create(
# 	name: 'disp_logon_link',
# 	category: 0,
# )
# s.system_param_values.create(
# 	value: 'TRUE',
# 	sort_order: 0
# )
# s = SystemParam.create(
# 	name: 'disp_forget_pw',
# 	category: 0,
# )
# s.system_param_values.create(
# 	value: 'TRUE',
# 	sort_order: 0
# )