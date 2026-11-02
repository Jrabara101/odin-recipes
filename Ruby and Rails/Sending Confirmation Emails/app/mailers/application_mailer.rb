class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@flightbooker.com"
  layout "mailer"
end
