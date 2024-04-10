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

ActiveRecord::Schema[7.1].define(version: 2024_04_10_004903) do
  create_table "auth_tokens", force: :cascade do |t|
    t.string "token"
    t.datetime "expires_at"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_auth_tokens_on_token"
    t.index ["user_id"], name: "index_auth_tokens_on_user_id"
  end

  create_table "blob_data", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_id"], name: "index_blob_data_on_blob_id"
  end

  create_table "blobs", id: :string, force: :cascade do |t|
    t.string "file_name"
    t.integer "size"
    t.string "path"
    t.integer "storage_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_blobs_on_id", unique: true
    t.index ["storage_type_id"], name: "index_blobs_on_storage_type_id"
  end

  create_table "storage_types", force: :cascade do |t|
    t.string "type_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
  end

  add_foreign_key "auth_tokens", "users"
  add_foreign_key "blob_data", "blobs"
  add_foreign_key "blobs", "storage_types"
end
