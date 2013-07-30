class SessionsController < ApplicationController
  def new
    @user=User.new
  end

  def create
    user = User.find_by_name(params[:name])
    if user && user.authenticate(params[:password])
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
      puts user.login_times
      login_times = user.login_times+1
      user.update_attribute(:login_times, login_times)
      redirect_to root_path
    else
      flash.now[:error]="could not log in!"
      render 'new'
    end
  end

  def delete
    cookies[:auth_token]=nil
    redirect_to root_path,notice:"you have logged out"
  end
end

