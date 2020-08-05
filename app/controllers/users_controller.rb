class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user, only: [:edit]
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info, :update_basic_info]

  def index
    @q = User.ransack(params[:q])
    @users = @q.result(distinct: true).where.not(users:{id:1}).paginate(page: params[:page]).order(id:"asc")
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

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :department, :password_confirmation,
                                    :basic_time, :employee_number, :uid,
                                    :designated_start_time, :designated_end_time)
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
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

end
