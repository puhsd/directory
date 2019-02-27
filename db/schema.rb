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

ActiveRecord::Schema.define(version: 2017_11_02_181949) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "object_guid"
    t.string "dn"
    t.string "displayname"
    t.string "samaccountname"
    t.string "mail"
    t.string "grouptype"
    t.datetime "ldap_imported_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.index ["dn"], name: "index_groups_on_dn", unique: true
    t.index ["object_guid"], name: "index_groups_on_object_guid", unique: true
    t.index ["slug"], name: "index_groups_on_slug", unique: true
  end

  create_table "groups_users", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.index ["group_id"], name: "index_groups_users_on_group_id"
    t.index ["user_id"], name: "index_groups_users_on_user_id"
  end

  create_table "request_updates", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "request_id"
    t.integer "state", default: 0
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_id"], name: "index_request_updates_on_request_id"
    t.index ["user_id"], name: "index_request_updates_on_user_id"
  end

  create_table "requests", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "firstname"
    t.string "lastname"
    t.integer "title_id"
    t.integer "employeetype"
    t.string "accountname"
    t.string "email"
    t.integer "site_id"
    t.string "employeenumber"
    t.datetime "startdate"
    t.datetime "enddate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "noenddate"
    t.integer "req_type", default: 0
    t.string "department"
    t.integer "state", default: 0
    t.index ["site_id"], name: "index_requests_on_site_id"
    t.index ["title_id"], name: "index_requests_on_title_id"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "sites", id: :serial, force: :cascade do |t|
    t.string "abbr"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "titles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.boolean "public", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "object_guid"
    t.string "username"
    t.datetime "ldap_imported_at"
    t.hstore "ldap_attributes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "access_level", default: 0
    t.string "avatar"
    t.string "slug"
    t.string "distinguishedname"
    t.string "link"
    t.boolean "active", default: true
    t.index ["distinguishedname"], name: "index_users_on_distinguishedname", unique: true
    t.index ["object_guid"], name: "index_users_on_object_guid", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "groups_users", "groups"
  add_foreign_key "groups_users", "users"
  add_foreign_key "request_updates", "requests"
  add_foreign_key "request_updates", "users"
  add_foreign_key "requests", "sites"
  add_foreign_key "requests", "titles"
  add_foreign_key "requests", "users"
end
