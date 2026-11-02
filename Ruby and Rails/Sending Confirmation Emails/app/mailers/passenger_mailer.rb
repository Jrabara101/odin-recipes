class PassengerMailer < ApplicationMailer
  # Sends a ticket confirmation email to a passenger.
  # Supports both direct argument invocation:
  #   PassengerMailer.confirmation_email(passenger).deliver_now!
  # and ActionMailer parameterized invocation:
  #   PassengerMailer.with(passenger: passenger).confirmation_email.deliver_later
  def confirmation_email(passenger = nil)
    @passenger = passenger || (params && params[:passenger])
    raise ArgumentError, "A passenger object must be provided" unless @passenger

    @booking = @passenger.booking
    @flight = @booking.flight
    @departure_airport = @flight.departure_airport
    @arrival_airport = @flight.arrival_airport
    @url = booking_url(@booking)

    mail(
      to: %("#{@passenger.name}" <#{@passenger.email}>),
      subject: "✈️ Flight Booking Confirmation - #{@flight.flight_number} (#{@booking.booking_reference})"
    )
  end
end
