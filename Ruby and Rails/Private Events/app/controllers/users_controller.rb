class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show, :index]

  def index
    @users = User.order(name: :asc)
  end

  def show
    @user = User.find(params[:id])
    # The Odin Project instruction:
    # "Keep this logic in the view and do not put separate method calls in the controller."
    # So we simply pass @user and let the view query @user.created_events and @user.attended_events
  end
end
