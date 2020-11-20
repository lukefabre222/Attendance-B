class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user, only: [:edit]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info, :attended]
  before_action :reguler_user, only: [:show]

  def index
    @q = User.ransack(params[:q])
    @users = @q.result(distinct: true).where.not(admin: true).paginate(page: params[:page]).order(id:"asc")
  end

  def import
    if params[:file].present?
      User.import(params[:file])
      redirect_to users_path
    else
      flash[:danger] = "ファイルを選択してください" 
      redirect_to users_path
    end
  end


  def show
    @user = User.find(params[:id])
    @first_day = first_day(params[:first_day])
    @last_day = @first_day.end_of_month
    (@first_day..@last_day).each do |day|
      unless @user.attendances.any? {|attendance| attendance.worked_on == day}
        record = @user.attendances.build(worked_on: day)
        record.save
      end
    end
    @dates = user_attendances_month_date
    @worked_sum = @dates.where.not(started_at: nil).count
    @superiors = User.where(superior: true).where.not(id: current_user.id)

    respond_to do |format|
      format.html
      format.csv{ send_data @dates.generate_csv, filename: "attendances-#{Time.zone.now.strftime("%Y%m%d%S")}.csv"}
    end
  end


  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] ="ユーザーの新規作成に成功しました。"
      redirect_to @user
    else
      render "new"
    end
  end

  def edit

  end

  def update
    if current_user.admin?
      @user = User.find(params[:id])
      if @user.update_attributes(user_params)
        flash[:success] = "ユーザー情報を更新しました"
        redirect_to users_path
      else
        render 'edit'
      end
    else
      correct_user
      if @user.update_attributes(user_params)
        flash[:success] = "ユーザー情報を更新しました"
        redirect_to user_path
      else
        render 'edit'
      end
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "削除しました"
    redirect_to users_url
  end

  def edit_basic_info
    @user = User.find(params[:id])
  end

  def update_basic_info
    @user = User.find(params[:id])
    if @user.update_attributes(basic_info_params)
      flash[:success] ="基本情報を更新しました"
      redirect_to @user
    else 
      render 'edit_basic_info'
    end
  end

  def attended
    @users = User.joins(:attendances).where(attendances:{worked_on: Date.today}).where.not(attendances: {started_at: nil}).where(attendances:{finished_at: nil})
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :department, :password_confirmation,
                                    :basic_time, :employee_number, :uid,
                                    :designated_work_start_time, :designated_work_end_time)
    end

    def basic_info_params
      params.require(:user).permit(:basic_time, :work_time)
    end

    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください"
        redirect_to login_url
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
      flash[:danger] = "権限がないため、TOPへ戻りました"
    end

    def admin_user
      unless current_user.admin?
        redirect_to(root_url)
        flash[:danger] = "管理者権限でログインしてください"
      end
    end

    def reguler_user
      redirect_to(root_url) if current_user.admin?
    end

end
