# Seed file for Odin Flight Booker
puts "Clearing existing data..."
Passenger.delete_all
Booking.delete_all
Flight.delete_all
Airport.delete_all

puts "Creating airports..."
airports_data = [
  { code: "SFO", city: "San Francisco", name: "San Francisco International Airport" },
  { code: "NYC", city: "New York", name: "John F. Kennedy International Airport" },
  { code: "LAX", city: "Los Angeles", name: "Los Angeles International Airport" },
  { code: "ORD", city: "Chicago", name: "O'Hare International Airport" },
  { code: "MIA", city: "Miami", name: "Miami International Airport" },
  { code: "SEA", city: "Seattle", name: "Seattle-Tacoma International Airport" },
  { code: "DFW", city: "Dallas", name: "Dallas/Fort Worth International Airport" },
  { code: "BOS", city: "Boston", name: "Boston Logan International Airport" }
]

airports = airports_data.map do |data|
  Airport.create!(data)
end
airport_by_code = airports.index_by(&:code)

puts "Creating flights..."
# Typical route durations in minutes
durations = {
  ["SFO", "NYC"] => 335, ["NYC", "SFO"] => 365,
  ["SFO", "LAX"] => 85,  ["LAX", "SFO"] => 90,
  ["SFO", "ORD"] => 250, ["ORD", "SFO"] => 275,
  ["SFO", "SEA"] => 130, ["SEA", "SFO"] => 135,
  ["LAX", "NYC"] => 320, ["NYC", "LAX"] => 350,
  ["LAX", "ORD"] => 235, ["ORD", "LAX"] => 255,
  ["LAX", "DFW"] => 180, ["DFW", "LAX"] => 195,
  ["NYC", "MIA"] => 190, ["MIA", "NYC"] => 185,
  ["NYC", "BOS"] => 75,  ["BOS", "NYC"] => 70,
  ["ORD", "DFW"] => 145, ["DFW", "ORD"] => 140,
  ["SEA", "LAX"] => 170, ["LAX", "SEA"] => 165,
  ["DFW", "MIA"] => 170, ["MIA", "DFW"] => 180,
  ["BOS", "ORD"] => 160, ["ORD", "BOS"] => 150
}

# Generate flights over the next 14 days
today = Date.current
flight_count = 0
times_of_day = [
  { hour: 6, min: 30 },
  { hour: 9, min: 15 },
  { hour: 11, min: 45 },
  { hour: 14, min: 20 },
  { hour: 17, min: 0 },
  { hour: 19, min: 45 },
  { hour: 21, min: 30 }
]

flight_number_seq = 100

(0..14).each do |day_offset|
  date = today + day_offset.days

  durations.each do |(from_code, to_code), duration_mins|
    dep = airport_by_code[from_code]
    arr = airport_by_code[to_code]
    next unless dep && arr

    # Pick 2 to 3 flight times per route per day
    selected_times = times_of_day.sample(rand(2..4))
    selected_times.each do |tod|
      flight_number_seq += 1
      flight_time = date.to_time.change(hour: tod[:hour], min: tod[:min])

      Flight.create!(
        departure_airport: dep,
        arrival_airport: arr,
        start_datetime: flight_time,
        duration: duration_mins,
        flight_number: "SKY-#{flight_number_seq}"
      )
      flight_count += 1
    end
  end
end

puts "Created #{Airport.count} airports and #{flight_count} flights across 15 days."
