class Attendance < ApplicationRecord
  belongs_to :user

  validates :worked_on, presence: true


  def self.csv_headers
    [
      "出勤日",
      "出社",
      "退社"
    ]
  end
  
  def started_at_csv
    if change_started_at.present?
      change_started_at.strftime("%H:%M")
    elsif started_at.present?
      started_at.strftime("%H:%m")
    else
      started_at = nil
      return started_at
    end
  end

  def finished_at_csv
    if change_finished_at.present?
      change_finished_at.strftime("%H:%M")
    elsif finished_at.present?
      finished_at.strftime("%H:%m")
    else
      finished_at = nil
      return finished_at
    end
  end

  def csv_column_values
    [
      worked_on.strftime("%m/%d"),
      started_at_csv,
      finished_at_csv
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
