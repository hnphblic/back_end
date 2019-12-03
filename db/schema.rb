# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_190_826_074_149) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'order', primary_key: 'order_id', id: :bigint, force: :cascade do |t|
    t.bigint 'user_id'
    t.integer 'money', null: false
    t.integer 'type', null: false
    t.datetime 'create_date', precision: 6, default: -> { 'CURRENT_TIMESTAMP' }, null: false
    t.bigint 'create_user_id'
  end


  create_table 'master_division', primary_key: %w[division_kind_num division_value], force: :cascade do |t|
    t.integer 'division_kind_num', null: false
    t.text 'division_kind_name', null: false
    t.integer 'division_value', null: false
    t.text 'division_name_ja', null: false
    t.text 'division_name_en', null: false
    t.datetime 'create_date', precision: 6, default: -> { 'CURRENT_TIMESTAMP' }, null: false
  end

  create_table 'system_param', force: :cascade do |t|
    t.string 'name', null: false
    t.integer 'category', null: false
  end

  create_table 'system_param_value', primary_key: %w[system_param_id sort_order], force: :cascade do |t|
    t.bigint 'system_param_id', null: false
    t.string 'value', null: false
    t.integer 'sort_order', null: false
  end

  create_table 'user_info', force: :cascade do |t|
    t.string 'username'
    t.string 'password', null: false
    t.string 'email'
    t.string 'user_create'
    t.datetime 'last_login', precision: 6
    t.datetime 'update_date', precision: 6
    t.datetime 'delete_date', precision: 6
    t.boolean 'is_deleted', default: false, null: false
    t.datetime 'create_date', precision: 6, default: -> { 'CURRENT_TIMESTAMP' }, null: false
  end

  create_table 'user_role', primary_key: 'user_id', id: :bigint, default: nil, force: :cascade do |t|
    t.boolean 'is_lock', default: false, null: false
    t.integer 'money', default: 0, null: false
    t.string 'ip_access'
    t.integer 'percent', default: 0, null: false
    t.integer 'agency', default: 0, null: false
    t.datetime 'update_date', precision: 6
  end

  create_table 'user_session_info', primary_key: %w[user_id name], force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.string 'name', null: false
    t.string 'value', null: false
  end

  create_table 'modem', force: :cascade do |t|
    t.string 'name', null: false
    t.integer 'index', null: false
    t.string 'status'
    t.integer 'current_bank'
    t.string 'Note'
    t.datetime 'update_date', precision: 6
    t.datetime 'create_date', precision: 6, default: -> { 'CURRENT_TIMESTAMP' }, null: false
  end

  create_table 'phone', primary_key: %w[id_modem number], force: :cascade do |t|
    t.string 'number', null: false
    t.string 'password', null: false
    t.string 'status', null: false
    t.bigint 'money', null: false
    t.datetime 'create_date', precision: 6, default: -> { 'CURRENT_TIMESTAMP' }, null: false
    t.datetime 'update_date', precision: 6
  end

  create_table 'history', primary_key: %w[user_id], force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.string 'SendPhone', null: false
    t.string 'ReceivePhone', null: false
    t.string 'Status', null: false
    t.string 'FristMoney', null: false
    t.string 'LastMoney', null: false
    t.string 'SendMoney', null: false
    t.string 'Note'
    t.datetime 'create_date', precision: 6, default: -> { 'CURRENT_TIMESTAMP' }, null: false
  end

  add_foreign_key 'order', 'user_info', column: 'user_id', on_delete: :cascade
  add_foreign_key 'system_param_value', 'system_param', on_delete: :cascade
  add_foreign_key 'user_role', 'user_info', column: 'user_id', on_delete: :cascade
  add_foreign_key 'user_session_info', 'user_info', column: 'user_id', on_delete: :cascade
end
