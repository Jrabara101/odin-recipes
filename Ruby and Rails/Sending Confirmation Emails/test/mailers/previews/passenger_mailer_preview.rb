# Preview all emails at http://localhost:3000/rails/mailers/passenger_mailer
class PassengerMailerPreview < ActionMailer::Preview
  def confirmation_email
    passenger = Passenger.first || create_sample_passenger
    PassengerMailer.confirmation_email(passenger)
  end

  private

  def create_sample_passenger
    sfo = Airport.find_or_create_by!(code: "SFO", city: "San Francisco", name: "San Francisco International Airport")
    jfk = Airport.find_or_create_by!(code: "JFK", city: "New York", name: "John F. Kennedy International Airport")
    flight = Flight.first || Flight.create!(
      departure_airport: sfo,
      arrival_airport: jfk,
      start_datetime: 3.days.from_now.change(hour: 10, min: 0),
      duration: 330,
      flight_number: "AERO-101"
    )
    booking = Booking.new(flight: flight)
    passenger = booking.passengers.build(name: "Sample Traveler", email: "traveler@example.com")
    booking.save!
    passenger
  end
end

