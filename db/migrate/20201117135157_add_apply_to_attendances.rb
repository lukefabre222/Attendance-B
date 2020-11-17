class AddApplyToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :apply_started_at, :datetime
    add_column :attendances, :apply_finished_at, :datetime
  end
end
