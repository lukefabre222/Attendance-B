class Attendance < ApplicationRecord
  belongs_to :user

  validates :worked_on, presence: true


  def self.csv_headers
    [
      "出勤日",
      "勤務開始時間",
      "勤務終了時間",
      "変更後勤務開始時間",
      "変更後勤務終了時間"
    ]
  end

  def csv_column_values
    [
      worked_on,
      started_at, 
      finished_at, 
      change_started_at, 
      change_finished_at
    ]
    
  end

  def self.generate_csv
    CSV.generate(encoding:Encoding::SJIS, headers: true) do |csv|

      csv << csv_headers
      all.each do |attendance|
        csv << attendance.csv_column_values
      end
    end
  end
  
end
