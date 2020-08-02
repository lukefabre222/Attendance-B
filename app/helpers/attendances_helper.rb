module AttendancesHelper
  def current_time
    Time.new(
      Time.now.year,
      Time.now.month,
      Time.now.day,
      Time.now.hour,
      Time.now.min, 0
    )
  end

  def working_times(started_at, finished_at)
    format("%.2f", (((finished_at - started_at) / 60) / 60.0))
  end
  
  def working_times_sum(seconds)
    format("%.2f", seconds/60/60.0)
  end

  def over_work_times(overtime_end_time, designated_work_end_time)
    finish_time = overtime_end_time.hour + overtime_end_time.min/60.0
    default_time = designated_work_end_time.hour + designated_work_end_time.min/60.0
    format("%.2f", (finish_time-default_time))
  end

  def first_day(date)
    !date.nil? ? Date.parse(date) : Date.current.beginning_of_month
  end

  def user_attendances_month_date
    @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
  end
  
  def attendances_invalid?
    attendances = true
    attendances_params.each do |id, item|
      if item[:started_at].blank? && item[:finished_at].blank?
        next
      elsif item[:started_at].blank? || item[:finished_at].blank?
        attendances = false
        break
      elsif item[:started_at] > item[:finished_at]
        attendances = false
        break
      end
    end
    return attendances
  end

  def change_attendances?
    change_attendances = true
    attendances_params.each do |id, item|
      if item[:change_superior_id].blank?
        change_attendances = false
      else
        change_attendances = true
        break
      end
    end
    return change_attendances
  end

  def checked_month_apply?
    month_apply_check = true
    confirmation_month_apply_params.each do |id, item|
      if item[:month_apply_check] == "0"
        month_apply_check = false
      elsif item[:month_apply_check] == "1"
        month_apply_check = true
        break
      end
    end
    month_apply_check
  end

  def checked_overtime_apply?
    overtime_apply_check = true
    confirmation_overtime_apply_params.each do |id, item|
      if item[:overtime_check] == "0"
        overtime_apply_check = false
      elsif item[:overtime_check] == "1"
        overtime_apply_check = true
        break
      end
    end
    overtime_apply_check
  end

  def checked_change_apply?
    change_check = true
    confirmation_change_apply_params.each do |id, item|
      if item[:change_check] == "0"
        change_check = false
      elsif item[:change_chack] = "1"
        change_check = true
        break
      end
    end
    change_check
  end

  #　１ヶ月勤怠申請が自分に来ているか
  def has_month_apply
    User.joins(:attendances).where(attendances: {superior_id: current_user.id}).where(attendances: {month_apply_status: "申請中"})
  end
  #  残業申請が自分に来ているか
  def has_overtime_apply
    User.joins(:attendances).where(attendances: {overtime_superior_id: current_user.id}).where(attendances: {overtime_apply_status: "申請中"})
  end
  # 変更申請が自分に来ているか
  def has_change_apply
    User.joins(:attendances).where(attendances: {change_superior_id: current_user.id}).where(attendances: {change_status: "申請中"})
  end

  # 1ヶ月承認待ちのユーザー
  def month_applying_users
    User.joins(:attendances).where.not(attendances:{superior_id: nil}).where(attendances: {month_apply_status: "申請中"})
  end
  # 残業承認まちのユーザー
  def overtime_applying_users
    User.joins(:attendances).where.not(attendances:{overtime_superior_id: nil}).where(attendances:{overtime_apply_status: "申請中"}).distinct
  end
  # 変更承認待ちのユーザー
  def change_applying_users
    User.joins(:attendances).where.not(attendances:{change_superior_id: nil}).where(attendances:{change_status: "申請中"}).distinct
  end
end
