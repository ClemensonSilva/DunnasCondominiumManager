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

ActiveRecord::Schema[8.1].define(version: 2026_04_16_204714) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "apartments", force: :cascade do |t|
    t.bigint "building_id", null: false
    t.datetime "created_at", null: false
    t.integer "floor"
    t.string "identificator"
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_apartments_on_building_id"
  end

  create_table "apartments_users", id: false, force: :cascade do |t|
    t.bigint "apartment_id", null: false
    t.bigint "user_id", null: false
  end

  create_table "buildings", force: :cascade do |t|
    t.integer "apartments_per_floor"
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "number_of_floors"
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "ticket_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["ticket_id"], name: "index_comments_on_ticket_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "condominia", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "scopes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "scopes_users", id: false, force: :cascade do |t|
    t.bigint "scope_id", null: false
    t.bigint "user_id", null: false
  end

  create_table "ticket_statuses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_default"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "ticket_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "scope_id", null: false
    t.integer "sla_hours"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["scope_id"], name: "index_ticket_types_on_scope_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.bigint "apartment_id", null: false
    t.string "attachments"
    t.bigint "collaborator_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "finished_at"
    t.bigint "ticket_status_id", null: false
    t.bigint "ticket_type_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["apartment_id"], name: "index_tickets_on_apartment_id"
    t.index ["collaborator_id"], name: "index_tickets_on_collaborator_id"
    t.index ["ticket_status_id"], name: "index_tickets_on_ticket_status_id"
    t.index ["ticket_type_id"], name: "index_tickets_on_ticket_type_id"
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.string "password_digest"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.integer "user_type"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "apartments", "buildings"
  add_foreign_key "comments", "tickets"
  add_foreign_key "comments", "users"
  add_foreign_key "ticket_types", "scopes"
  add_foreign_key "tickets", "apartments"
  add_foreign_key "tickets", "ticket_statuses"
  add_foreign_key "tickets", "ticket_types"
  add_foreign_key "tickets", "users"
  add_foreign_key "tickets", "users", column: "collaborator_id"
end
