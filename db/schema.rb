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

ActiveRecord::Schema.define(version: 20161208153159) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree
  end

  create_table "groups", force: :cascade do |t|
    t.string   "object_guid"
    t.string   "dn"
    t.string   "displayname"
    t.string   "samaccountname"
    t.string   "mail"
    t.string   "grouptype"
    t.datetime "ldap_imported_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "slug"
    t.index ["dn"], name: "index_groups_on_dn", unique: true, using: :btree
    t.index ["object_guid"], name: "index_groups_on_object_guid", unique: true, using: :btree
    t.index ["slug"], name: "index_groups_on_slug", unique: true, using: :btree
  end

  create_table "groups_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.index ["group_id"], name: "index_groups_users_on_group_id", using: :btree
    t.index ["user_id"], name: "index_groups_users_on_user_id", using: :btree
  end

  create_table "titles", force: :cascade do |t|
    t.string   "name"
    t.boolean  "public",     default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "object_guid"
    t.string   "username"
    t.datetime "ldap_imported_at"
    t.hstore   "ldap_attributes"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "access_level",      default: 0
    t.string   "avatar"
    t.string   "slug"
    t.string   "distinguishedname"
    t.string   "link"
    t.boolean  "active",            default: true
    t.index ["distinguishedname"], name: "index_users_on_distinguishedname", unique: true, using: :btree
    t.index ["object_guid"], name: "index_users_on_object_guid", unique: true, using: :btree
    t.index ["slug"], name: "index_users_on_slug", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  add_foreign_key "groups_users", "groups"
  add_foreign_key "groups_users", "users"
end
