class AddIndexOfficesOfficeNumber < ActiveRecord::Migration[5.2]
  def change
    add_index :offices, :office_number, unique: true
  end
end
