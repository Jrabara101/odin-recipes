class PostsController < ApplicationController
  before_action :set_post, only: [:show, :destroy]

  def index
    @post = Post.new
    @posts = current_user.feed_posts
    @pending_requests = current_user.pending_friend_requests_received.limit(5)
    friend_ids = current_user.friends.pluck(:id) + [current_user.id]
    @suggested_users = User.where.not(id: friend_ids).limit(5)
  end

  def show
  end

  def create
    @post = current_user.posts.build(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to root_path, notice: "Post created successfully!" }
        format.turbo_stream
      else
        @posts = current_user.feed_posts
        @pending_requests = current_user.pending_friend_requests_received.limit(5)
        friend_ids = current_user.friends.pluck(:id) + [current_user.id]
        @suggested_users = User.where.not(id: friend_ids).limit(5)
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @post.user == current_user
      @post.destroy
      respond_to do |format|
        format.html { redirect_to root_path, notice: "Post deleted successfully." }
        format.turbo_stream
      end
    else
      redirect_to root_path, alert: "You are not authorized to delete this post."
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:content, :image)
  end
end

