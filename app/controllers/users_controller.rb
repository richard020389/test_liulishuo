class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.online_minutes = 0
    @user.login_times = 0
    if @user.save
      redirect_to root_url, notice: "Signed up!"
    else
      flash.now[:error]=@user.errors.full_messages.join("<br/>").html_safe
      render "new"
    end
  end

end
