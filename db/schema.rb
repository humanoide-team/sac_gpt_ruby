# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_01_09_001656) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "name"
    t.string "password"
    t.datetime "deleted_at"
    t.string "slug"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "credit_cards", force: :cascade do |t|
    t.bigint "partner_id", null: false
    t.string "brand"
    t.string "holder_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "number"
    t.string "expires_at"
    t.integer "galax_pay_id"
    t.string "galax_pay_my_id"
    t.boolean "default"
    t.index ["partner_id"], name: "index_credit_cards_on_partner_id"
  end

  create_table "faq_items", force: :cascade do |t|
    t.string "title"
    t.string "body"
    t.integer "sequence"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "partner_id", null: false
    t.string "title"
    t.string "description"
    t.integer "notification_type"
    t.boolean "readed", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "metadata"
    t.index ["partner_id"], name: "index_notifications_on_partner_id"
  end

  create_table "partner_client_conversation_infos", force: :cascade do |t|
    t.bigint "partner_id", null: false
    t.bigint "partner_client_id", null: false
    t.text "system_conversation_resume"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partner_client_id"], name: "index_partner_client_conversation_infos_on_partner_client_id"
    t.index ["partner_id"], name: "index_partner_client_conversation_infos_on_partner_id"
  end

  create_table "partner_client_leads", force: :cascade do |t|
    t.bigint "partner_id", null: false
    t.bigint "partner_client_id", null: false
    t.text "conversation_summary"
    t.text "lead_classification"
    t.integer "lead_score"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "token_count"
    t.index ["partner_client_id"], name: "index_partner_client_leads_on_partner_client_id"
    t.index ["partner_id"], name: "index_partner_client_leads_on_partner_id"
  end

  create_table "partner_client_messages", force: :cascade do |t|
    t.bigint "partner_id", null: false
    t.bigint "partner_client_id", null: false
    t.text "message"
    t.text "automatic_response"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "webhook_uuid"
    t.index ["partner_client_id"], name: "index_partner_client_messages_on_partner_client_id"
    t.index ["partner_id"], name: "index_partner_client_messages_on_partner_id"
  end

  create_table "partner_clients", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email"
  end

  create_table "partner_details", force: :cascade do |t|
    t.bigint "partner_id", null: false
    t.string "about"
    t.string "company"
    t.string "service"
    t.string "service_list"
    t.string "product_list"
    t.string "persona"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name_attendant"
    t.string "company_name"
    t.string "company_niche"
    t.string "served_region"
    t.string "company_services"
    t.string "company_products"
    t.string "company_contact"
    t.string "company_objectives", default: [], array: true
    t.string "main_goals"
    t.string "business_goals"
    t.string "marketing_channels"
    t.string "key_differentials"
    t.string "target_audience"
    t.string "tone_voice"
    t.string "preferential_language"
    t.index ["partner_id"], name: "index_partner_details_on_partner_id"
  end

  create_table "partner_payments", force: :cascade do |t|
    t.bigint "partner_id", null: false
    t.bigint "credit_card_id", null: false
    t.string "status"
    t.string "pagarme_transaction"
    t.string "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["credit_card_id"], name: "index_partner_payments_on_credit_card_id"
    t.index ["partner_id"], name: "index_partner_payments_on_partner_id"
  end

  create_table "partners", force: :cascade do |t|
    t.string "name"
    t.string "service_number"
    t.string "password"
    t.datetime "deleted_at"
    t.string "slug"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "instance_key"
    t.string "document"
    t.string "contact_number"
    t.integer "galax_pay_id"
    t.string "galax_pay_my_id"
    t.boolean "active", default: false
    t.string "calendar_token"
    t.string "access_token"
    t.datetime "expires_at"
    t.string "refresh_token"
  end

  create_table "payment_plans", force: :cascade do |t|
    t.string "name"
    t.integer "periodicity"
    t.integer "quantity"
    t.string "additional_info"
    t.integer "plan_price_payment"
    t.string "plan_price_value"
    t.string "galax_pay_my_id"
    t.integer "galax_pay_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "payment_subscriptions", force: :cascade do |t|
    t.date "first_pay_day_date"
    t.string "additional_info"
    t.integer "main_payment_method_id"
    t.bigint "partner_id", null: false
    t.bigint "credit_card_id", null: false
    t.bigint "payment_plan_id", null: false
    t.integer "status"
    t.string "payment_link"
    t.integer "galax_pay_id"
    t.string "galax_pay_my_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["credit_card_id"], name: "index_payment_subscriptions_on_credit_card_id"
    t.index ["partner_id"], name: "index_payment_subscriptions_on_partner_id"
    t.index ["payment_plan_id"], name: "index_payment_subscriptions_on_payment_plan_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "schedule_type"
    t.string "summary"
    t.string "description"
    t.datetime "date_time_start"
    t.datetime "date_time_end"
    t.string "event"
    t.bigint "partner_id", null: false
    t.bigint "partner_client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partner_client_id"], name: "index_schedules_on_partner_client_id"
    t.index ["partner_id"], name: "index_schedules_on_partner_id"
  end

  create_table "waiting_list_clients", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "credit_cards", "partners"
  add_foreign_key "notifications", "partners"
  add_foreign_key "partner_client_conversation_infos", "partner_clients"
  add_foreign_key "partner_client_conversation_infos", "partners"
  add_foreign_key "partner_client_leads", "partner_clients"
  add_foreign_key "partner_client_leads", "partners"
  add_foreign_key "partner_client_messages", "partner_clients"
  add_foreign_key "partner_client_messages", "partners"
  add_foreign_key "partner_details", "partners"
  add_foreign_key "partner_payments", "credit_cards"
  add_foreign_key "partner_payments", "partners"
  add_foreign_key "payment_subscriptions", "credit_cards"
  add_foreign_key "payment_subscriptions", "partners"
  add_foreign_key "payment_subscriptions", "payment_plans"
  add_foreign_key "schedules", "partner_clients"
  add_foreign_key "schedules", "partners"
end
