class AddApprovedColmunToAttendances < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :approved_date, :datetime
  end
end
