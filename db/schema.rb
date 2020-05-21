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

ActiveRecord::Schema.define(version: 20200520104029) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "apps", force: :cascade do |t|
    t.text "name", null: false
    t.text "description"
    t.text "repository_name", null: false
    t.text "env_template"
    t.boolean "auto_deploy", default: false
    t.text "auto_deploy_branch", default: "master"
    t.text "job_spec", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "image_source", default: "ecr", null: false
    t.index ["name"], name: "index_apps_on_name", unique: true
  end

  create_table "graylog_streams", force: :cascade do |t|
    t.string "stream_id"
    t.string "stream_name"
    t.string "stream_rule_value"
    t.string "index_set"
    t.bigint "app_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "index_graylog_streams_on_app_id"
  end

  add_foreign_key "graylog_streams", "apps"
end
