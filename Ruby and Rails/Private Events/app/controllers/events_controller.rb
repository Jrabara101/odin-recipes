class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :invite, :toggle_privacy]
  before_action :authorize_creator!, only: [:edit, :update, :destroy, :invite, :toggle_privacy]

  def index
    base_events = if user_signed_in?
      Event.left_outer_joins(:event_attendances)
           .where("events.private = ? OR events.creator_id = ? OR event_attendances.attendee_id = ?", false, current_user.id, current_user.id)
           .distinct
    else
      Event.public_events
    end

    @upcoming_events = base_events.upcoming
    @past_events = base_events.past
  end

  def show
    unless @event.visible_to?(current_user)
      redirect_to events_path, alert: "This event is private. You need an invitation from the host to view it."
      return
    end

    @attendees = @event.attendees
    @attendance = @event.event_attendances.find_by(attendee: current_user) if user_signed_in?
    @potential_invitees = User.where.not(id: (@event.attendee_ids + [@event.creator_id]).uniq) if current_user == @event.creator
  end

  def new
    @event = current_user.created_events.build
  end

  def create
    @event = current_user.created_events.build(event_params)

    if @event.save
      # Automatically enroll creator as attending their own event
      @event.event_attendances.create(attendee: current_user, status: "attending")
      redirect_to @event, notice: "Event was successfully created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "Event was successfully updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: "Event was successfully deleted."
  end

  def invite
    user_to_invite = User.find(params[:user_id])
    attendance = @event.event_attendances.build(attendee: user_to_invite, status: "invited")

    if attendance.save
      redirect_to @event, notice: "Invited #{user_to_invite.name} (@#{user_to_invite.username}) successfully!"
    else
      redirect_to @event, alert: "Could not invite user: #{attendance.errors.full_messages.join(', ')}"
    end
  end

  def toggle_privacy
    @event.update(private: !@event.private)
    redirect_to @event, notice: "Event visibility changed to #{@event.private? ? 'Private' : 'Public'}."
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def authorize_creator!
    unless @event.creator == current_user
      redirect_to @event, alert: "You are not authorized to perform this action."
    end
  end

  def event_params
    params.require(:event).permit(:title, :description, :location, :date, :private)
  end
end
