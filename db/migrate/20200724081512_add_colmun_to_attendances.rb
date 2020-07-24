class AddColmunToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :month_apply_check, :integer
  end
end
