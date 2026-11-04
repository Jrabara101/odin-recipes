class CommentsController < ApplicationController
  before_action :set_post

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_back fallback_location: root_path, notice: "Comment added!" }
        format.turbo_stream
      else
        format.html { redirect_back fallback_location: root_path, alert: "Could not add comment: #{@comment.errors.full_messages.to_sentence}" }
      end
    end
  end

  def destroy
    @comment = @post.comments.find(params[:id])
    if @comment.user == current_user || @post.user == current_user
      @comment.destroy
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: "Comment deleted." }
        format.turbo_stream
      end
    else
      redirect_back fallback_location: root_path, alert: "You are not authorized to delete this comment."
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end

