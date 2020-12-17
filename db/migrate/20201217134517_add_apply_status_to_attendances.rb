class AddApplyStatusToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :apply_overtime_end_time, :datetime
    add_column :attendances, :apply_overtime_detail, :string
    add_column :attendances, :apply_note, :string
  end
end
