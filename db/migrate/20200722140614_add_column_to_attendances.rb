class AddColumnToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :superior_id, :integer
    add_column :attendances, :month_apply_status, :string
    add_column :attendances, :month_apply_date, :datetime
  end
end
