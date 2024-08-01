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

ActiveRecord::Schema.define(version: 2024_07_23_163618) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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

  create_table "affiliate_bank_details", force: :cascade do |t|
    t.bigint "affiliate_id", null: false
    t.string "responsible"
    t.string "document_number"
    t.string "bank_code"
    t.string "agency"
    t.string "account"
    t.integer "account_type", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "pix_code"
    t.index ["affiliate_id"], name: "index_affiliate_bank_details_on_affiliate_id"
  end

  create_table "affiliate_client_conversation_infos", force: :cascade do |t|
    t.bigint "affiliate_id", null: false
    t.bigint "affiliate_client_id", null: false
    t.text "system_conversation_resume"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["affiliate_client_id"], name: "index_affiliate_client_convo_infos_on_aff_client_id"
    t.index ["affiliate_id"], name: "index_affiliate_client_convo_infos_on_affiliate_id"
  end

  create_table "affiliate_client_leads", force: :cascade do |t|
    t.bigint "affiliate_id", null: false
    t.bigint "affiliate_client_id", null: false
    t.text "conversation_summary"
    t.text "lead_classification"
    t.integer "lead_score"
    t.integer "token_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["affiliate_client_id"], name: "index_affiliate_client_leads_on_affiliate_client_id"
    t.index ["affiliate_id"], name: "index_affiliate_client_leads_on_affiliate_id"
  end

  create_table "affiliate_client_messages", force: :cascade do |t|
    t.bigint "affiliate_id", null: false
    t.bigint "affiliate_client_id", null: false
    t.bigint "conversation_thread_id"
    t.text "message"
    t.text "automatic_response"
    t.string "webhook_uuid"
    t.string "open_ai_message_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["affiliate_client_id"], name: "index_affiliate_client_messages_on_affiliate_client_id"
    t.index ["affiliate_id"], name: "index_affiliate_client_messages_on_affiliate_id"
    t.index ["conversation_thread_id"], name: "index_affiliate_client_messages_on_conversation_thread_id"
  end

  create_table "affiliate_clients", force: :cascade do |t|
    t.bigint "affiliate_id", null: false
    t.string "name"
    t.string "phone"
    t.string "email"
    t.boolean "blocked", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["affiliate_id"], name: "index_affiliate_clients_on_affiliate_id"
  end

  create_table "affiliate_credit_cards", force: :cascade do |t|
    t.bigint "affiliate_id", null: false
    t.string "brand"
    t.string "holder_name"
    t.string "number"
    t.string "expires_at"
    t.integer "galax_pay_id"
    t.string "galax_pay_my_id"
    t.boolean "default"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["affiliate_id"], name: "index_affiliate_credit_cards_on_affiliate_id"
  end

  create_table "affiliate_extra_tokens", force: :cascade do |t|
    t.integer "token_quantity"
    t.bigint "affiliate_id", null: false
    t.bigint "affiliate_payment_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["affiliate_id"], name: "index_affiliate_extra_tokens_on_affiliate_id"
    t.index ["affiliate_payment_id"], name: "index_affiliate_extra_tokens_on_affiliate_payment_id"
  end

  create_table "affiliate_montly_usage_histories", force: :cascade do |t|
    t.bigint "affiliate_id", null: false
    t.date "period"
    t.integer "token_count", default: 0
    t.integer "extra_token_count", default: 0
    t.boolean "exceed_mail", default: false
    t.boolean "exceed_extra_token_mail", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["affiliate_id"], name: "index_affiliate_montly_usage_histories_on_affiliate_id"
  end

  create_table "affiliate_payments", force: :cascade do |t|
    t.integer "galax_pay_id"
    t.string "galax_pay_my_id"
    t.string "galax_pay_plan_my_id"
    t.integer "plan_galax_pay_id"
    t.integer "main_payment_method_id"
    t.string "payment_link"
    t.integer "value"
    t.string "additional_info"
    t.integer "status"
    t.date "payday"
    t.bigint "affiliate_id", null: false
    t.bigint "affiliate_credit_card_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["affiliate_credit_card_id"], name: "index_affiliate_payments_on_affiliate_credit_card_id"
    t.index ["affiliate_id"], name: "index_affiliate_payments_on_affiliate_id"
  end

  create_table "affiliate_test_bot_leads", force: :cascade do |t|
    t.bigint "affiliate_id", null: false
    t.text "conversation_summary"
    t.text "lead_classification"
    t.integer "lead_score", default: 0
    t.integer "token_count", default: 0
    t.string "test_bot_mail"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["affiliate_id"], name: "index_affiliate_test_bot_leads_on_affiliate_id"
  end

  create_table "affiliate_test_bot_messages", force: :cascade do |t|
    t.bigint "affiliate_id", null: false
    t.text "message"
    t.text "automatic_response"
    t.boolean "read", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["affiliate_id"], name: "index_affiliate_test_bot_messages_on_affiliate_id"
  end

  create_table "affiliates", force: :cascade do |t|
    t.string "name"
    t.string "contact_number"
    t.string "service_number"
    t.string "email"
    t.string "password"
    t.string "document"
    t.boolean "active", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "instance_key"
    t.datetime "deleted_at"
    t.string "slug"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token", default: ""
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "revenue_percentage", default: 10
    t.integer "galax_pay_id"
    t.string "galax_pay_my_id"
    t.boolean "wpp_connected", default: true
    t.datetime "last_callback_receive"
  end

  create_table "bot_configurations", force: :cascade do |t|
    t.bigint "affiliate_id", null: false
    t.string "about"
    t.string "service"
    t.string "persona"
    t.string "name_attendant"
    t.string "company_name"
    t.string "company_niche"
    t.string "served_region"
    t.string "company_services"
    t.string "company_products"
    t.string "company_contact"
    t.string "company_objectives", default: [], array: true
    t.string "marketing_channels"
    t.string "key_differentials"
    t.string "tone_voice", default: [], array: true
    t.string "preferential_language"
    t.string "catalog_link"
    t.integer "token_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "prospect_card_id"
    t.index ["affiliate_id"], name: "index_bot_configurations_on_affiliate_id"
    t.index ["prospect_card_id"], name: "index_bot_configurations_on_prospect_card_id"
  end

  create_table "conversation_threads", force: :cascade do |t|
    t.string "open_ai_thread_id"
    t.bigint "partner_id", null: false
    t.bigint "partner_client_id", null: false
    t.bigint "partner_assistent_id", null: false
    t.string "open_ai_last_run_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partner_assistent_id"], name: "index_conversation_threads_on_partner_assistent_id"
    t.index ["partner_client_id"], name: "index_conversation_threads_on_partner_client_id"
    t.index ["partner_id"], name: "index_conversation_threads_on_partner_id"
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

  create_table "extra_tokens", force: :cascade do |t|
    t.integer "token_quantity"
    t.bigint "partner_id", null: false
    t.bigint "payment_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partner_id"], name: "index_extra_tokens_on_partner_id"
    t.index ["payment_id"], name: "index_extra_tokens_on_payment_id"
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

  create_table "montly_usage_histories", force: :cascade do |t|
    t.date "period"
    t.integer "token_count", default: 0
    t.bigint "partner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "exceed_mail", default: false
    t.boolean "almost_exceed", default: false
    t.boolean "half_exceed", default: false
    t.boolean "extra_token_half_exceed", default: false
    t.boolean "extra_token_almost_exceed", default: false
    t.boolean "exceed_extra_token_mail", default: false
    t.integer "extra_token_count", default: 0
    t.index ["partner_id"], name: "index_montly_usage_histories_on_partner_id"
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
    t.boolean "pop_up", default: false
    t.index ["partner_id"], name: "index_notifications_on_partner_id"
  end

  create_table "partner_assistents", force: :cascade do |t|
    t.string "open_ai_assistent_id"
    t.bigint "partner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partner_id"], name: "index_partner_assistents_on_partner_id"
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
    t.bigint "conversation_thread_id"
    t.string "open_ai_message_id"
    t.index ["conversation_thread_id"], name: "index_partner_client_messages_on_conversation_thread_id"
    t.index ["partner_client_id"], name: "index_partner_client_messages_on_partner_client_id"
    t.index ["partner_id"], name: "index_partner_client_messages_on_partner_id"
  end

  create_table "partner_clients", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email"
    t.bigint "partner_id"
    t.boolean "blocked", default: false
    t.index ["partner_id"], name: "index_partner_clients_on_partner_id"
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
    t.string "tone_voice", default: [], array: true
    t.string "preferential_language"
    t.string "details_resume"
    t.datetime "details_resume_date"
    t.string "catalog_link"
    t.string "twitter_x_link"
    t.string "youtube_link"
    t.string "facebook_link"
    t.string "instagram_link"
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

  create_table "partner_test_bot_leads", force: :cascade do |t|
    t.bigint "partner_id", null: false
    t.text "conversation_summary"
    t.text "lead_classification"
    t.integer "lead_score", default: 0
    t.integer "token_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "test_bot_mail"
    t.index ["partner_id"], name: "index_partner_test_bot_leads_on_partner_id"
  end

  create_table "partner_test_bot_messages", force: :cascade do |t|
    t.bigint "partner_id", null: false
    t.text "message"
    t.text "automatic_response"
    t.boolean "read", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partner_id"], name: "index_partner_test_bot_messages_on_partner_id"
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
    t.integer "galax_pay_id"
    t.string "galax_pay_my_id"
    t.string "document"
    t.string "contact_number"
    t.boolean "active", default: false
    t.string "calendar_token"
    t.string "access_token"
    t.datetime "expires_at"
    t.string "refresh_token"
    t.bigint "affiliate_id"
    t.boolean "wpp_connected", default: true
    t.datetime "last_callback_receive"
    t.string "remote_jid"
    t.string "company_name"
    t.index ["affiliate_id"], name: "index_partners_on_affiliate_id"
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
    t.integer "max_token_count"
    t.boolean "disable", default: false
    t.integer "cost_per_thousand_toukens"
  end

  create_table "payment_subscriptions", force: :cascade do |t|
    t.date "first_pay_day_date"
    t.string "additional_info"
    t.integer "main_payment_method_id"
    t.bigint "partner_id", null: false
    t.bigint "credit_card_id"
    t.bigint "payment_plan_id", null: false
    t.integer "status"
    t.string "payment_link"
    t.integer "galax_pay_id"
    t.string "galax_pay_my_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "max_token_count", default: 0
    t.index ["credit_card_id"], name: "index_payment_subscriptions_on_credit_card_id"
    t.index ["partner_id"], name: "index_payment_subscriptions_on_partner_id"
    t.index ["payment_plan_id"], name: "index_payment_subscriptions_on_payment_plan_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "galax_pay_id"
    t.string "galax_pay_my_id"
    t.string "galax_pay_plan_my_id"
    t.integer "plan_galax_pay_id"
    t.integer "main_payment_method_id"
    t.string "payment_link"
    t.integer "value"
    t.string "additional_info"
    t.integer "status"
    t.bigint "partner_id", null: false
    t.bigint "credit_card_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "payday"
    t.index ["credit_card_id"], name: "index_payments_on_credit_card_id"
    t.index ["partner_id"], name: "index_payments_on_partner_id"
  end

  create_table "prompt_files", force: :cascade do |t|
    t.string "open_ai_file_id"
    t.bigint "partner_detail_id", null: false
    t.bigint "partner_assistent_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "file_name"
    t.index ["partner_assistent_id"], name: "index_prompt_files_on_partner_assistent_id"
    t.index ["partner_detail_id"], name: "index_prompt_files_on_partner_detail_id"
  end

  create_table "prospect_cards", force: :cascade do |t|
    t.bigint "affiliate_id", null: false
    t.string "name"
    t.string "phone"
    t.string "email"
    t.string "observations"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "test_active"
    t.string "company_name"
    t.string "status", default: "0"
    t.index ["affiliate_id"], name: "index_prospect_cards_on_affiliate_id"
  end

  create_table "prospect_details", force: :cascade do |t|
    t.bigint "prospect_card_id", null: false
    t.string "about"
    t.string "service"
    t.string "persona"
    t.string "name_attendant"
    t.string "company_name"
    t.string "company_niche"
    t.string "served_region"
    t.string "company_services"
    t.string "company_products"
    t.string "company_contact"
    t.string "company_objectives", default: [], array: true
    t.string "marketing_channels"
    t.string "key_differentials"
    t.string "tone_voice", default: [], array: true
    t.string "preferential_language"
    t.string "catalog_link"
    t.integer "token_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["prospect_card_id"], name: "index_prospect_details_on_prospect_card_id"
  end

  create_table "revenues", force: :cascade do |t|
    t.bigint "affiliate_id", null: false
    t.bigint "partner_id", null: false
    t.integer "value", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "partner_transaction_type"
    t.bigint "partner_transaction_id"
    t.index ["affiliate_id"], name: "index_revenues_on_affiliate_id"
    t.index ["partner_id"], name: "index_revenues_on_partner_id"
    t.index ["partner_transaction_type", "partner_transaction_id"], name: "index_revenues_on_partner_transaction"
  end

  create_table "schedule_settings", force: :cascade do |t|
    t.integer "duration_in_minutes"
    t.string "week_days"
    t.string "start_time"
    t.string "end_time"
    t.string "google_agenda_id"
    t.bigint "partner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "interval_minutes"
    t.index ["partner_id"], name: "index_schedule_settings_on_partner_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "schedule_type"
    t.string "summary"
    t.string "description"
    t.datetime "date_time_start"
    t.datetime "date_time_end"
    t.string "event"
    t.bigint "partner_id", null: false
    t.integer "partner_client_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partner_client_id"], name: "index_schedules_on_partner_client_id"
    t.index ["partner_id"], name: "index_schedules_on_partner_id"
  end

  create_table "token_usages", force: :cascade do |t|
    t.bigint "partner_client_id", null: false
    t.string "model"
    t.integer "prompt_tokens", default: 0
    t.integer "completion_tokens", default: 0
    t.integer "total_tokens", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partner_client_id"], name: "index_token_usages_on_partner_client_id"
  end

  create_table "waiting_list_clients", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "affiliate_bank_details", "affiliates"
  add_foreign_key "affiliate_client_conversation_infos", "affiliate_clients"
  add_foreign_key "affiliate_client_conversation_infos", "affiliates"
  add_foreign_key "affiliate_client_leads", "affiliate_clients"
  add_foreign_key "affiliate_client_leads", "affiliates"
  add_foreign_key "affiliate_client_messages", "affiliate_clients"
  add_foreign_key "affiliate_client_messages", "affiliates"
  add_foreign_key "affiliate_client_messages", "conversation_threads"
  add_foreign_key "affiliate_clients", "affiliates"
  add_foreign_key "affiliate_credit_cards", "affiliates"
  add_foreign_key "affiliate_extra_tokens", "affiliate_payments"
  add_foreign_key "affiliate_extra_tokens", "affiliates"
  add_foreign_key "affiliate_montly_usage_histories", "affiliates"
  add_foreign_key "affiliate_payments", "affiliate_credit_cards"
  add_foreign_key "affiliate_payments", "affiliates"
  add_foreign_key "affiliate_test_bot_leads", "affiliates"
  add_foreign_key "affiliate_test_bot_messages", "affiliates"
  add_foreign_key "bot_configurations", "affiliates"
  add_foreign_key "bot_configurations", "prospect_cards"
  add_foreign_key "conversation_threads", "partner_assistents"
  add_foreign_key "conversation_threads", "partner_clients"
  add_foreign_key "conversation_threads", "partners"
  add_foreign_key "credit_cards", "partners"
  add_foreign_key "extra_tokens", "partners"
  add_foreign_key "extra_tokens", "payments"
  add_foreign_key "montly_usage_histories", "partners"
  add_foreign_key "notifications", "partners"
  add_foreign_key "partner_assistents", "partners"
  add_foreign_key "partner_client_conversation_infos", "partner_clients"
  add_foreign_key "partner_client_conversation_infos", "partners"
  add_foreign_key "partner_client_leads", "partner_clients"
  add_foreign_key "partner_client_leads", "partners"
  add_foreign_key "partner_client_messages", "conversation_threads"
  add_foreign_key "partner_client_messages", "partner_clients"
  add_foreign_key "partner_client_messages", "partners"
  add_foreign_key "partner_clients", "partners"
  add_foreign_key "partner_details", "partners"
  add_foreign_key "partner_payments", "credit_cards"
  add_foreign_key "partner_payments", "partners"
  add_foreign_key "partner_test_bot_leads", "partners"
  add_foreign_key "partner_test_bot_messages", "partners"
  add_foreign_key "partners", "affiliates"
  add_foreign_key "payment_subscriptions", "credit_cards"
  add_foreign_key "payment_subscriptions", "partners"
  add_foreign_key "payment_subscriptions", "payment_plans"
  add_foreign_key "payments", "credit_cards"
  add_foreign_key "payments", "partners"
  add_foreign_key "prompt_files", "partner_assistents"
  add_foreign_key "prompt_files", "partner_details"
  add_foreign_key "prospect_cards", "affiliates"
  add_foreign_key "prospect_details", "prospect_cards"
  add_foreign_key "revenues", "affiliates"
  add_foreign_key "revenues", "partners"
  add_foreign_key "schedule_settings", "partners"
  add_foreign_key "schedules", "partner_clients"
  add_foreign_key "schedules", "partners"
  add_foreign_key "token_usages", "partner_clients"
end
