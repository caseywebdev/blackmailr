# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Blackmailr::Application.initialize!

# Set delivery method to SMTP in order to use gmail to delivery emails through Heroku
ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
   :address => "smtp.gmail.com",
   :port => 587,
   :domain => "blackmailr.heroku.com",
   :user_name => "rlewis10001@gmail.com",
   :password => "testing473",
   :authentication => :plain,
   :enable_starttls_auto => true,
   :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE
}

ActionMailer::Base.raise_delivery_errors = true
