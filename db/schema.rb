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

ActiveRecord::Schema.define(version: 2021_01_13_141238) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "superior_id"
    t.string "month_apply_status"
    t.datetime "month_apply_date"
    t.integer "month_apply_check"
    t.integer "overtime_superior_id"
    t.string "overtime_apply_status"
    t.datetime "overtime_end_time"
    t.integer "overtime_check"
    t.string "overtime_detail"
    t.integer "next_day_check"
    t.integer "change_superior_id"
    t.string "change_status"
    t.integer "change_check"
    t.datetime "change_started_at"
    t.datetime "change_finished_at"
    t.integer "change_next_day_check"
    t.datetime "approved_date"
    t.datetime "apply_started_at"
    t.datetime "apply_finished_at"
    t.datetime "apply_overtime_end_time"
    t.string "apply_overtime_detail"
    t.string "apply_note"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "offices", force: :cascade do |t|
    t.integer "office_number"
    t.string "office_name"
    t.string "attendance_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["office_number"], name: "index_offices_on_office_number", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.boolean "admin", default: false
    t.string "department"
    t.datetime "basic_time", default: "2019-02-19 22:30:00"
    t.datetime "work_time", default: "2019-02-19 23:00:00"
    t.boolean "superior", default: false
    t.datetime "designated_work_start_time", default: "2019-02-20 01:00:00"
    t.datetime "designated_work_end_time", default: "2019-02-20 09:00:00"
    t.string "uid"
    t.integer "employee_number"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "attendances", "users"
end
