class LikesController < ApplicationController
  before_action :set_post

  def create
    @like = @post.likes.find_or_create_by(user: current_user)

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path }
      format.turbo_stream
    end
  end

  def destroy
    @like = @post.likes.find_by(id: params[:id], user: current_user) || @post.likes.find_by(user: current_user)
    @like&.destroy

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path }
      format.turbo_stream
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end

