class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      flash[:success] ="ログインに成功しました"
      if user.admin?
        redirect_to root_path
      else
        redirect_back_or user
      end
    else
      flash.now[:danger] = 'メールアドレスとパスワードの情報が一致しませんでした。'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end