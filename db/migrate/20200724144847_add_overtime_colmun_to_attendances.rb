class AddOvertimeColmunToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :overtime_superior_id, :integer
    add_column :attendances, :overtime_apply_status, :string
    add_column :attendances, :overtime_end_time, :datetime
    add_column :attendances, :overtime_check, :integer
    add_column :attendances, :overtime_detail, :string
    add_column :attendances, :next_day_check, :integer
  end
end
