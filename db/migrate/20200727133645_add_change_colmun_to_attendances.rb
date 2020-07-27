class AddChangeColmunToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :change_superior_id, :integer
    add_column :attendances, :change_status, :string
    add_column :attendances, :change_check, :integer
    add_column :attendances, :change_started_at, :datetime
    add_column :attendances, :change_finished_at, :datetime
    add_column :attendances, :change_next_day_check, :integer
  end
end
