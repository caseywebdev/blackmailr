class BlackmailController < ApplicationController
  before_filter :authenticate, :only => [:new, :create, :edit]
  
  def index
  end

  def show
  	@user=User.find_by_remember_token(cookies[:remember_token])
  	@blackmail=@user.blackmail.all
    if @blackmail.empty?
      redirect_to :new
    end
  end
  
  def new
    @blackmail = Blackmail.new
  end
  
  def create
    @blackmail = Blackmail.new params[:blackmail]
    @blackmail.user_id = current_user
    params[:demands][:description] #or just [:demands?]
      .split("\n")
      .map(&:clean)
      .select { |s| not s.empty? }
      .each { |description| @blackmail.demands.new description: description }
    if @blackmail.save
      #upload image:
            #get the picture from the form
            upload = params[:img_location]
            name =  "#{@blackmail.id}_0.jpg"
            directory = "#{Rails.root}/app/assets/images/blackmail"
            # create the file path
            path = File.join(directory, name)
            # write the file
            File.open(path, 'wb') { |f| f.write upload.read }
            #TODO: resize with rmagic before save
      # rl: Send blackmail_email after save
      # Note that rails doesn't send email by default from development environment
      # View console for confirmation that email is properly formed
      puts 'Victim Email'+params[:blackmail][:victim_email]
      UserMailer.blackmail_email(params[:blackmail]).deliver
      
      flash[:success] = 'Blackmail successfully sent!'
      
      # TODO: Redirect user to list of all user blackmails
      redirect_to :root

    else
      # Re-render the blackmail page if problem occurs.
      render 'new' 
    end
  end
  
  def edit 
  	@blackmail=Blackmail.find_by_id(params[:id])
  	render 'edit'
  end
  
  def update
    @blackmail = Blackmail.find_by_id(params[:id])
  	@blackmail.user_id = current_user
    if @blackmail.update_attributes(params[:blackmail])
      flash[:success] = "Blackmail updated."
      redirect_to :home
    else
      flash.now[:error] = 'Error occured when updating Blackmail'
      render 'edit'
    end
  end

  def destroy
  end
  
private

    def authenticate
      deny_access unless signed_in?
    end
  
end
