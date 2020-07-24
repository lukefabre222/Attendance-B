class AttendancesController < ApplicationController

  def create
    @user = User.find(params[:user_id])
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
  end

  def update
    @user = User.find(params[:id])
    if attendances_invalid?
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes(item)
      end
      flash[:success] = "勤怠情報を更新しました。"
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

  def notice_month_apply
    @users = month_applying_users #@usersに１ヶ月承認待ちのユーザーを代入
  end

  def confirmation_month_apply
    confirmation_month_apply_params.each do |id, item|
      if item[:month_apply_check] == "0"
        flash[:danger] = "チェックを入れてから、送信してください"
        redirect_back(fallback_location: root_path)
        return
      else
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
        flash[:success] = "#{item[:month_apply_status]}が完了しました"
        redirect_to user_url(:id => current_user.id)
        return
      end
    end
  end

  private
    # 1ヶ月更新時のstrong_params
    def attendances_params
      params.permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end

    # １ヶ月申請時のstrong_params
    def month_apply_params
      params.permit(attendances: [:superior_id, :month_apply_status, :month_apply_date])[:attendances]
    end
    # １ヶ月承認時のstrong_params
    def confirmation_month_apply_params
      params.permit(attendances: [:month_apply_status, :month_apply_check])[:attendances]
    end

end
