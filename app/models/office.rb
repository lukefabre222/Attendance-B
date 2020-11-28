class Office < ApplicationRecord
  validates :office_name, presence: true
  validates :office_number, uniqueness: true, 
                            numericality: { only_integer: true,
                                            greater_than: 0, less_than: 100}
end
