class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]

  def index
    @tab = params[:tab] || "all"
    case @tab
    when "friends"
      @users = current_user.friends.order(:first_name)
    when "requests"
      @received_requests = current_user.pending_friend_requests_received
      @sent_requests = current_user.pending_friend_requests_sent
    else
      @users = User.where.not(id: current_user.id).order(:first_name)
    end
  end

  def show
    @posts = @user.posts.includes(:likes, comments: :user).with_attached_image.order(created_at: :desc)
    @friendship = current_user.friendship_with(@user)
    @friends = @user.friends.limit(9)
  end

  def edit
    redirect_to root_path, alert: "Not authorized." unless @user == current_user
  end

  def update
    if @user == current_user && @user.update(user_params)
      redirect_to @user, notice: "Profile updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :username, :bio, :avatar)
  end
end

