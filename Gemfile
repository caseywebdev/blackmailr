source "https://rubygems.org"

# Rails
gem "rails"

# For has_secure_password
gem "bcrypt-ruby"

# Recaptcha
gem "recaptcha", :require => "recaptcha/rails"

# HAML
gem "haml-rails"

# Email validation
gem "validate_email"

group :assets do
  gem "sass-rails"
  gem "coffee-rails"
  gem "uglifier"
  gem "compass-rails"
	gem "jquery-rails"
  gem "compass-rails"
end

group :development, :test do
	gem "sqlite3"
	gem "rspec-rails"
  gem "guard-bundler"
  gem "guard-rspec"
  gem "guard-spork"
	gem "growl"
  gem "rb-fsevent"
  gem "syntax"
  gem "capybara"
end

group :production do
	gem "pg"
end
