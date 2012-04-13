class UserMailer < ActionMailer::Base
  default from: "admin@blackmailr.com"
  
  # Send when new users sign up
  def welcome_email(user)
    @user = user
    @url  = root_path
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
