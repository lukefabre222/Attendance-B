class CreateOffices < ActiveRecord::Migration[5.2]
  def change
    create_table :offices do |t|
      t.integer :office_number
      t.string :office_name
      t.string :attendance_status

      t.timestamps
    end
  end
end
