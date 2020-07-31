class AttendancesController < ApplicationController
  def create
    @user = User.find(params[:id])
    @attendance = @user.attendances.find_by(worked_on: Date.today)
    if @attendance.started_at.nil?
      @attendance.update_attributes(started_at: current_time)
      flash[:info] = "おはようございます。"
    elsif @attendance.finished_at.nil?
      @attendance.update_attributes(finished_at: current_time)
      flash[:info] = "お疲れ様でした。"
    else
      flash[:danger] = "トラブルがあり、登録できませんでした"
    end
    redirect_to @user
  end

  def edit
    @user = User.find(params[:id])
    @first_day = first_day(params[:date])
    @last_day = @first_day.end_of_month
    @dates = user_attendances_month_date
    @superiors = User.where(superior: true).where.not(id: current_user.id)
  end

  def update
    @user = User.find(params[:id])
    if attendances_invalid?
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:change_superior_id].present?
          attendance.update_attributes!(change_status: "申請中",
                                        note: item[:note], 
                                        change_next_day_check: item[:change_next_day_check], 
                                        change_superior_id: item[:change_superior_id],                                          change_started_at: item[:started_at], 
                                        change_finished_at: item[:finished_at])
        else
          attendance.update_attributes!(note: item[:note],
                                        change_next_day_check: item[:change_next_day_check])
        end
      end
        flash[:success] = "勤怠変更を申請しました。"
        redirect_to user_url(@user, params:{first_day: params[:date]})
    else
        flash[:danger] = "不正な時間入力がありました、再入力してください"
        redirect_to edit_attendances_path(@user, params[:date])   
    end
  end


  def update_month_apply
    @user = User.find(params[:id])
    month_apply_params.each do |id, item|
      if item[:superior_id].blank?
        flash[:danger] = "申請先の上長を選択してください"
        redirect_to user_url(date: params[:date])
      else
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
        flash[:success] = "申請が完了しました"
        redirect_back(fallback_location: root_path)
      end
    end
  end

  def update_overtime_apply
    @user = User.find(params[:id])
    overtime_apply_params.each do |id, item|
      if item[:overtime_superior_id].blank?
        flash[:danger] = "申請先の上長を選択してください"
        redirect_to user_url(date: params[:date])
      else
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
        flash[:success] = "残業申請が完了しました"
        redirect_back(fallback_location: root_path)
      end
    end
  end

  def notice_month_apply
    @users = month_applying_users #@usersに１ヶ月承認待ちのユーザーを代入 helperに記載
  end

  def notice_overtime_apply
    @users = overtime_applying_users #@usersに残業申請中のユーザーを代入　helperに記載  
  end

  def notice_change_apply
    @users = change_applying_users # @userに勤怠変更申請中のユーザーを代入　helperに記載
  end

  def overtime_apply
    @superiors = User.where(superior: true).where.not(id: current_user.id)
  end

  def confirmation_month_apply
    if checked_month_apply?
      confirmation_month_apply_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
      flash[:success] = "１ヶ月勤怠申請の決済を更新しました"
      redirect_to user_url(:id => current_user.id)
    else
      flash[:danger] = "チェックを入れてから、送信してください"
      redirect_back(fallback_location: root_path)
    end
  end

  def confirmation_overtime_apply
    if checked_overtime_apply?
      confirmation_overtime_apply_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
      flash[:success] = "残業申請の更新が完了しました"
      redirect_back(fallback_location: root_path)
    else
      flash[:danger] = "チェックを入れてから、送信してください"
      redirect_to user_url(:id => current_user.id)
    end
  end

  def confirmation_change_apply
    if checked_change_apply?
      confirmation_change_apply_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
      flash[:success] = "勤怠変更申請の更新が完了しました"
      redirect_back(fallback_location: root_path)
    else
      flash[:danger] = "チェックを入れてから、送信してください"
      redirect_to user_url(:id => current_user.id)
    end
  end

  def approved_attendance
    @approved_attendances = Attendance.where(attendances:{change_status: "承認"}).where(attendances:{user_id: current_user.id})
  end

  private
    # 1ヶ月更新時のstrong_params
    def attendances_params
      params.permit(attendances: [:started_at, :finished_at, :note, :change_next_day_check, :change_superior_id,
                                  :change_status])[:attendances]
    end
    # １ヶ月申請時のstrong_params
    def month_apply_params
      params.permit(attendances: [:superior_id, :month_apply_status, :month_apply_date])[:attendances]
    end
    # １ヶ月承認時のstrong_params
    def confirmation_month_apply_params
      params.permit(attendances: [:month_apply_status, :month_apply_check])[:attendances]
    end
    #残業申請時のstrong_params
    def overtime_apply_params
      params.permit(attendances: [:overtime_end_time,:next_day_check, :overtime_detail,:overtime_superior_id, 
                                  :overtime_apply_status])[:attendances]
    end
    # 残業承認時のstrong_params
    def confirmation_overtime_apply_params
      params.permit(attendances: [:overtime_apply_status, :overtime_check])[:attendances]
    end

    def confirmation_change_apply_params
      params.permit(attendances: [:change_started_at, :change_finished_at, :change_status, :change_check])[:attendances]
    end
end
