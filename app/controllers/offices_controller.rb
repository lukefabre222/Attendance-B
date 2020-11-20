class OfficesController < ApplicationController

  before_action :admin_user

  def index
    @offices =Office.all
  end

  def new
    @office = Office.new
  end

  def edit
    @office = Office.find(params[:id])
  end

  def create
    @office = Office.new(office_params)
    if @office.save
      flash[:success] ="拠点の新規作成に成功しました。"
      redirect_to offices_path
    else
      render "new"
    end
  end

  def update
    @office = Office.find(params[:id])
    if @office.update_attributes(office_params)
      flash[:success] = "拠点情報を更新しました"
      redirect_to offices_path
    else
      render 'edit'
    end

  end

  def destroy
    Office.find(params[:id]).destroy
    flash[:success] = "削除しました"
    redirect_to offices_path
  end

  private

  def office_params
    params.require(:office).permit(:office_number, :office_name, :attendance_status)
  end

  def admin_user
    unless current_user.admin?
      redirect_to(root_url)
      flash[:danger] = "管理者権限でログインしてください"
    end
  end
end
