class AttendancesController < ApplicationController
  before_action :reguler_user, only:[:create, :edit, :update, :update_month_apply, :update_overtime_apply]

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
    @superiors = User.where(superior: true).where.not(id: current_user.id)
  end
  
  def update
    @user = User.find(params[:id])
    if attendances_invalid?
      update_count = 0
      attendances_params.each do |id, item|
        if item[:change_superior_id].present?
          attendance = Attendance.find(id) 
          if attendance.change_started_at.present? && attendance.change_finished_at.present?
            attendance.update_attributes!(change_status: "申請中",
              apply_note: item[:note], 
              change_next_day_check: item[:change_next_day_check], 
              change_superior_id: item[:change_superior_id], 
              apply_started_at: item[:change_started_at], 
              apply_finished_at: item[:change_finished_at])
              update_count = update_count + 1
          else
            attendance.update_attributes!(change_status: "申請中",
              apply_note: item[:note], 
              change_next_day_check: item[:change_next_day_check], 
              change_superior_id: item[:change_superior_id], 
              apply_started_at: item[:started_at], 
              apply_finished_at: item[:finished_at])
              update_count = update_count +1
          end
        end
      end
      if update_count > 0
        flash[:success] = "勤怠変更を申請しました"
      else
        flash[:warning] = "勤怠を変更するには上長を選択してください"
      end
      redirect_to user_url(@user, date: params[:date])
    else
      flash[:danger] = "正しい時間を入力してください"
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
    confirmation_month_apply_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:month_apply_check] == "0"
        flash[:danger] = "変更にチェックが入っていない申請があります"
      elsif item[:month_apply_check] == "1"
        attendance.update_attributes!(item)
        flash[:success] = "１ヶ月勤怠申請の決済を更新しました"
      end
    end
    redirect_to user_url(:id => current_user.id)
  end

  def confirmation_overtime_apply
    confirmation_overtime_apply_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:overtime_check] == "0"
        flash[:danger] = "変更にチェックが入っていない申請があります"
      elsif item[:overtime_check] == "1"
        attendance.update_attributes!(item)
        flash[:success] = "残業申請の更新が完了しました"
      end
    end
    redirect_to user_url(:id => current_user.id)
  end

  def confirmation_change_apply
    confirmation_change_apply_params.each do |id, item|
      attendance = Attendance.find(id)
      if item[:change_check] == "0"
        flash[:danger] = "変更にチェックが入っていない申請があります"
      elsif item[:change_check] == "1"
        attendance.update_attributes!(change_started_at: item[:apply_started_at], 
                                      change_finished_at: item[:apply_finished_at], 
                                      change_status: item[:change_status], 
                                      change_check: item[:change_check], 
                                      approved_date: item[:approved_date],
                                      note: item[:apply_note])
        flash[:success] = "勤怠変更申請の更新が完了しました"
      end
    end
    redirect_to user_url(:id => current_user.id)
  end

  def approved_attendance
    @q = Attendance.ransack(params[:q])
    if params[:q].present?
      search_date = "#{params[:q]["worked_on(1i)"]}-#{params[:q]["worked_on(2i)"]}-1"
      @approved_attendances = @q.result(distinct: true).where(attendances:{user_id: current_user.id}).where(worked_on: search_date.in_time_zone.all_month).where.not(attendances:{change_started_at: [nil]})
    else
      @approved_attendances = @q.result(distinct: true).where(attendances:{user_id: current_user.id}).where.not(attendances:{change_started_at: [nil]})
    end
  end

  private
    # 1ヶ月更新時のstrong_params
    def attendances_params
      params.permit(attendances: [:started_at, :finished_at, :change_started_at, :change_finished_at, :note, 
                                  :change_next_day_check, :change_superior_id,
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
                                  :overtime_apply_status,:apply_overtime_end_time,:apply_overtime_detail])[:attendances]
    end
    # 残業承認時のstrong_params
    def confirmation_overtime_apply_params
      params.permit(attendances: [:overtime_apply_status, :overtime_check,:overtime_end_time,:overtime_detail,
                                  :apply_overtime_end_time, :apply_overtime_Detail])[:attendances]
    end

    def confirmation_change_apply_params
      params.permit(attendances: [:apply_started_at, :apply_finished_at, :change_status, :change_check, :approved_date, :apply_note])[:attendances]
    end

    def reguler_user
      redirect_to root_path if current_user.admin?
    end
end
