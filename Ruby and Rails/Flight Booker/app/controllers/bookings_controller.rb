class BookingsController < ApplicationController
  def new
    if params[:flight_id].blank?
      redirect_to root_path, alert: "Please select an available flight first."
      return
    end

    @flight = Flight.find(params[:flight_id])
    @num_tickets = (params[:num_tickets] || 1).to_i.clamp(1, 4)
    @booking = Booking.new(flight: @flight)

    @num_tickets.times { @booking.passengers.build }
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "The selected flight could not be found."
  end

  def create
    @booking = Booking.new(booking_params)
    @flight = @booking.flight

    if @booking.save
      redirect_to booking_path(@booking), notice: "🎉 Flight successfully booked! Your confirmation is ready below."
    else
      flash.now[:alert] = "Please fix the errors below to complete your booking."
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @booking = Booking.includes(:flight, :passengers).find(params[:id])
    @flight = @booking.flight
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Booking not found."
  end

  private

  def booking_params
    params.require(:booking).permit(
      :flight_id,
      passengers_attributes: [ :id, :name, :email, :_destroy ]
    )
  end
end
