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

  def working_times(started_at, finished_at, check_box)
    if check_box == 1
      format("%.2f", (((finished_at - started_at) / 60) / 60.0)+ 24 )
    else
      format("%.2f", (((finished_at - started_at) / 60) / 60.0))
    end
  end
  
  def working_times_sum(seconds)
    format("%.2f", seconds/60/60.0)
  end

  def over_work_times(overtime_end_time, designated_work_end_time, check_box)
    finish_time = overtime_end_time.hour + overtime_end_time.min/60.0
    default_time = designated_work_end_time.hour + designated_work_end_time.min/60.0
    if check_box == 1
      format("%.2f", (finish_time - default_time + 24 ))
    else
      format("%.2f", (finish_time - default_time))
    end
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
      elsif item[:started_at] > item[:finished_at] && item[:change_next_day_check] == "1"
        attendances = true
        break
      elsif item[:started_at] > item[:finished_at]
        attendances = false
        break
      end
    end
    return attendances
  end

  def change_attendances_invalid?
    change_attendances = true
    attendances_params.each do |id, item| 
      if item[:change_started_at].blank? && item[:change_finished_at].blank?
        next
      elsif item[:change_started_at].blank? || item[:change_finished_at].blank?
        change_attendances = false
        break
      elsif item[:change_started_at] > item[:change_finished_at] && item[:change_next_day_check] == "1"
        change_attendances = true
        break
      elsif item[:change_started_at] > item[:change_finished_at]
        change_attendances = false
        break
      end
    end
    return change_attendances
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
  # 未承認または否認の１ヶ月申請があるか
  def has_did_not_month_approved
    Attendance.where(user_id: current_user.id).where(month_apply_status: "申請中").or(Attendance.where(month_apply_status: "否認"))
  end
  # 未承認または否認の残業申請があるか
  def has_did_not_overtime_approved
    Attendance.where(user_id: current_user.id).where(overtime_apply_status: "申請中").or(Attendance.where(overtime_apply_status: "否認"))
  end
  # 未承認または否認の勤怠変更申請があるか
  def has_did_not_change_approved
    Attendance.where(user_id: current_user.id).where(change_status: "申請中").or(Attendance.where(change_status: "否認"))
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
