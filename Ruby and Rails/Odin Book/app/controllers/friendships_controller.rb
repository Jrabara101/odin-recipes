class FriendshipsController < ApplicationController
  def create
    receiver = User.find(params[:receiver_id])
    if current_user.send_friend_request(receiver)
      notice = "Friend request sent to #{receiver.full_name}!"
    else
      notice = "Unable to send friend request."
    end
    redirect_back fallback_location: users_path, notice: notice
  end

  def update
    friendship = current_user.received_friendships.find(params[:id])
    if params[:status] == "accepted"
      friendship.accept!
      notice = "You are now friends with #{friendship.sender.full_name}!"
    else
      friendship.reject!
      notice = "Friend request declined."
    end
    redirect_back fallback_location: users_path, notice: notice
  end

  def destroy
    friendship = Friendship.where(sender: current_user).or(Friendship.where(receiver: current_user)).find(params[:id])
    other_user = friendship.sender == current_user ? friendship.receiver : friendship.sender
    friendship.destroy
    redirect_back fallback_location: users_path, notice: "Friendship / request removed with #{other_user.full_name}."
  end
end

