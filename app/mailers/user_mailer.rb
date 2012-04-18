class UserMailer < ActionMailer::Base
  default from: "not_your_day@blackmailr.com"
  
  # Send when new users sign up
  def welcome_email(user)
    @user = user
    # Note: Unlike controllers, the mailer instance doesn’t have any context about the incoming request
    # Cite: http://guides.rubyonrails.org/action_mailer_basics.html#generating-urls-in-action-mailer-views
    @url  = user_url(user, :host => "blackmailr.com") # Specifies named route
    mail(:to => user.email, :subject => "Who says blackmail can't be fun?")
  end

  # Send blackmail email to victim
  def blackmail_email(victim)
    @victim_name = victim[:victim_name]    
    @victim_email = victim[:victim_email]
    @d_day = victim[:expired_at]
    @url = root_path
    #attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    mail(:to => victim[:victim_email], :subject => "You've been blackmailed")
  end
end
