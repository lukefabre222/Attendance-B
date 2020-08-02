class AddDesignatedtimeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :designated_work_start_time, :datetime, default: Time.zone.parse("2019/02/20 10:00")
    add_column :users, :designated_work_end_time, :datetime, default: Time.zone.parse("2019/02/20 18:00")
    add_column :users, :uid, :integer
    add_column :users, :employee_number, :integer
  end
end
