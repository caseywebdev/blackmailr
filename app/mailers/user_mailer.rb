class UserMailer < ActionMailer::Base
  default from: "noreply@blackmailr.heroku.com"
  
  # Send when new users sign up
  def welcome_email(user)
    @user = user
    # Note: Unlike controllers, the mailer instance doesn’t have any context about the incoming request
    # Cite: http://guides.rubyonrails.org/action_mailer_basics.html#generating-urls-in-action-mailer-views
    @url  = sign_in_url
    mail(:to => user.email, :subject => "Who says blackmail can't be fun, #{@user.email}?")
  end

  # Send blackmail email to victim
  def blackmail_email(blackmail)
    @victim_name = blackmail[:victim_name]    
    @victim_email = blackmail[:victim_email]
    @d_day = blackmail[:expired_at]
    dm = blackmail.demands      
    @victim_demands = blackmail.demands
    puts "Inside the mailer"    
    puts @victim_demands    
    @url  = blackmail.victim_view_url
    #attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    mail(:to => blackmail[:victim_email], :subject => "You've been blackmailed, #{@victim_name}")
  end
end
