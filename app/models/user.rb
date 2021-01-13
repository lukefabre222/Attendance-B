class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  before_save { self.email = email.downcase}
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, presence: true, length: {minimum:6}, allow_nil: true
  validates :department, length: {in:3..50}, allow_blank: true

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      user = new
      user.attributes = row.to_hash.slice(*updatable_attributes)
      user.save!(validates: false)
    end
  end

  def self.updatable_attributes
    [ "name", "email", "department", "employee_number", "uid", "basic_time", "designated_work _start_time",
      "designated_work_end_time", "superior", "admin", "password"]
  end
end