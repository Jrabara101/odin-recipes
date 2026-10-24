class EventAttendancesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event

  def create
    @attendance = @event.event_attendances.find_or_initialize_by(attendee: current_user)
    @attendance.status = "attending"

    if @attendance.save
      redirect_to @event, notice: "You are now registered as attending this event!"
    else
      redirect_to @event, alert: "Could not register attendance: #{@attendance.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @attendance = @event.event_attendances.find_by(attendee: current_user)

    if @attendance&.destroy
      redirect_to @event, notice: "You have removed yourself as an attendee from this event."
    else
      redirect_to @event, alert: "Attendance record not found."
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end
end
