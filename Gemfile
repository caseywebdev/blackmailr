source 'https://rubygems.org'

# Rails
gem 'rails'

# For has_secure_password
gem 'bcrypt-ruby'

# Recaptcha
gem 'recaptcha', :require => 'recaptcha/rails'

# HAML
gem 'haml-rails'

# Email validation
gem 'validate_email'

# SQLite
gem 'sqlite3', group: [:development, :test]

# PostgreSQL
gem 'pg', group: [:production]

# Testing gems
group :test do
  # Rspec
  gem 'rspec-rails'
  
  # Guard (better than autotest IMO)
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'guard-spork'
  
  # Growl is OS X only...
  gem 'growl'
  gem 'rb-fsevent'
  
  # Syntax highlighting in Rspec reports
  gem 'syntax'
  
  # Fancy dancy selector support in tests
  gem 'capybara'

  #adds model information
  gem 'annotate'
end

# Asset handlers
group :assets do
  # SCSS
  gem 'sass-rails'
  
  # CoffeeScript
  gem 'coffee-rails'
  
  # JS minifier
  gem 'uglifier'
  
  # Backbone.js and Underscore.js
  gem 'rails-backbone'
  
  # Compass CSS
  gem 'compass-rails'
  
  # jQuery
  gem 'jquery-rails'
end
