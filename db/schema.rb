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

ActiveRecord::Schema.define(version: 2023_05_24_234159) do

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
    t.string "first_digits"
    t.string "last_digits"
    t.string "brand"
    t.string "holder_name"
    t.string "pagarme_card_id"
    t.string "pagarme_subscription_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

  create_table "partner_client_messages", force: :cascade do |t|
    t.bigint "partner_id", null: false
    t.bigint "partner_client_id", null: false
    t.text "message"
    t.text "automatic_response"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partner_client_id"], name: "index_partner_client_messages_on_partner_client_id"
    t.index ["partner_id"], name: "index_partner_client_messages_on_partner_id"
  end

  create_table "partner_clients", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.string "phone"
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

  create_table "waiting_list_clients", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "credit_cards", "partners"
  add_foreign_key "partner_client_messages", "partner_clients"
  add_foreign_key "partner_client_messages", "partners"
  add_foreign_key "partner_details", "partners"
  add_foreign_key "partner_payments", "credit_cards"
  add_foreign_key "partner_payments", "partners"
end
