# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120812124936) do

  create_table "directions", :force => true do |t|
    t.text    "raw_text"
    t.integer "recipe_id"
  end

  create_table "icons", :force => true do |t|
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.integer  "recipe_id"
  end

  create_table "images", :force => true do |t|
    t.integer  "recipe_id"
    t.binary   "contents"
    t.string   "jpg_file_name"
    t.string   "jpg_content_type"
    t.integer  "jpg_file_size"
    t.datetime "jpg_updated_at"
    t.boolean  "has_styles"
    t.boolean  "twitter_style"
  end

  create_table "ingredients", :force => true do |t|
    t.string  "raw_text"
    t.integer "recipe_id"
    t.integer "ordinal"
  end

  create_table "recipes", :force => true do |t|
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                       :null => false
    t.text     "page"
    t.string   "state"
    t.boolean  "structured"
    t.string   "corrections", :default => ""
    t.integer  "site_id"
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "url",               :limit => 63
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "user_recipes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "recipe_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.boolean  "needs_prov_help", :default => true
  end

end
