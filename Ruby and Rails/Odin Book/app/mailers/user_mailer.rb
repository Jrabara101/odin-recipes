class UserMailer < ApplicationMailer
  default from: "notifications@odinbook.com"

  def welcome_email(user)
    @user = user
    @url = root_url(host: "localhost:3000")
    mail(to: @user.email, subject: "Welcome to OdinBook, #{@user.full_name}!")
  end
end

