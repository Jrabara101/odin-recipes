# ✉️ Flight Booker: Sending Confirmation Emails

An automated email confirmation system built on **Ruby on Rails 7**, designed for [The Odin Project: Sending Confirmation Emails](https://www.theodinproject.com/lessons/ruby-on-rails-sending-confirmation-emails).

This project enhances the Flight Booker reservation workflow by dispatching individualized flight confirmation and electronic ticket emails to **every passenger** created as part of the booking process.

---

## 🎯 Features & Architectural Highlights

1. **Per-Passenger Confirmation Mailings**:
   - Sends a personalized confirmation email to each passenger in a booking, rather than a single generic email for the entire booking.
   - Built with `PassengerMailer#confirmation_email(passenger)`.

2. **Multi-Part Email Templates (HTML & Plain Text)**:
   - **HTML (`app/views/passenger_mailer/confirmation_email.html.erb`)**: Modern, responsive airline ticket layout styled with Aero Airlines branding, complete with booking reference box, route timeline, passenger details, travel advisories, and an online boarding pass link.
   - **Plain Text (`app/views/passenger_mailer/confirmation_email.text.erb`)**: Clean, formatted ASCII itinerary for text-only email clients and accessibility.

3. **In-Browser Email Previewing with Letter Opener**:
   - Integrates the `letter_opener` gem in development mode.
   - Dispatches open instantly in your default web browser instead of sending real emails over SMTP.
   - Cross-platform support for Windows and WSL (`file://wsl.localhost/...`).

4. **Rails Action Mailer Previews**:
   - Native Rails mailer previews accessible at `http://localhost:3000/rails/mailers/passenger_mailer/confirmation_email`.
   - Allows instant visual inspection and testing of both HTML and text email variants without modifying database state.

5. **Automated Integration & Unit Test Coverage**:
   - Unit tests (`test/mailers/passenger_mailer_test.rb`) validating multipart formatting, subject headers, sender/recipient addresses, and parameterized invocations.
   - End-to-end integration tests (`test/integration/flight_booking_flow_test.rb`) confirming that booking creation delivers exactly one email per passenger.

---

## 🏗️ Mailer Architecture & Data Flow

```
   ┌────────────────────────────────────────────────────────┐
   │                    BookingsController                  │
   │               (POST /bookings #create)                 │
   └──────────────────────────┬─────────────────────────────┘
                              │
                    @booking.save successful
                              │
                              ▼
   ┌────────────────────────────────────────────────────────┐
   │             Iterate @booking.passengers               │
   │           PassengerMailer.confirmation_email(p)        │
   └──────────────┬───────────────────────────┬─────────────┘
                  │                           │
          Passenger #1                Passenger #2
                  │                           │
                  ▼                           ▼
   ┌───────────────────────────┐ ┌───────────────────────────┐
   │ PassengerMailer (Alice)   │ │ PassengerMailer (Bob)     │
   │ - To: alice@example.com   │ │ - To: bob@example.com     │
   │ - Ref: SKY-XXXXXX         │ │ - Ref: SKY-XXXXXX         │
   │ - HTML + Text views       │ │ - HTML + Text views       │
   └──────────────┬────────────┘ └─────────────┬─────────────┘
                  │                            │
                  ▼                            ▼
   ┌────────────────────────────────────────────────────────┐
   │                      Letter Opener                     │
   │      (Opens individual tabs in default web browser)     │
   │                  Saved to tmp/letter_opener            │
   └────────────────────────────────────────────────────────┘
```

---

## 🚀 Getting Started

### 1. Prerequisites
- **Ruby**: 3.3+
- **Rails**: 7.2+
- **Bundler**: 2.5+
- **SQLite3**

### 2. Installation & Setup

1. **Navigate to the Project Directory**:
   ```bash
   cd "c:\Users\Admin\odin-recipes\Ruby and Rails\Sending Confirmation Emails"
   ```

2. **Install Dependencies**:
   ```bash
   bundle install
   ```

3. **Prepare and Seed Database**:
   ```bash
   bin/rails db:prepare
   bin/rails db:seed
   ```

4. **Start the Rails Server**:
   ```bash
   bin/rails server -p 3000
   ```

5. **Test in Browser**:
   - Visit `http://localhost:3000` to book a flight with 1 to 4 passengers.
   - Once submitted, `letter_opener` will automatically open the confirmation email(s) in your browser!
   - You can also view Action Mailer previews at `http://localhost:3000/rails/mailers/passenger_mailer/confirmation_email`.

---

## 💻 Rails Console Testing

You can call the mailer directly from the Rails console:

```ruby
bin/rails console
```

Inside the console:

```ruby
# Fetch the first passenger (or create one)
passenger = Passenger.first

# Deliver the confirmation email immediately via letter_opener
PassengerMailer.confirmation_email(passenger).deliver_now!
```

---

## 🧪 Running the Test Suite

Run all unit and integration tests:

```bash
bundle exec ruby -I test test/mailers/passenger_mailer_test.rb
bundle exec ruby -I test test/integration/flight_booking_flow_test.rb
```

All tests run in isolation with `ActionMailer::Base.delivery_method = :test`, verifying delivery counts and body contents.

---

## 🌐 Production Deployment & SendGrid Setup (Extra Credit)

To send real emails in production (e.g., deployed to Heroku, Render, or Fly.io):

1. **Add production SMTP configuration** in `config/environments/production.rb`:
   ```ruby
   config.action_mailer.delivery_method = :smtp
   config.action_mailer.perform_deliveries = true
   config.action_mailer.raise_delivery_errors = true
   config.action_mailer.default_url_options = { host: "your-app-domain.com" }

   config.action_mailer.smtp_settings = {
     address:              "smtp.sendgrid.net",
     port:                 587,
     domain:               "your-app-domain.com",
     user_name:            "apikey",
     password:             ENV["SENDGRID_API_KEY"],
     authentication:       :plain,
     enable_starttls_auto: true
   }
   ```
2. **Environment Variable**: Set `SENDGRID_API_KEY` on your hosting provider dashboard.
