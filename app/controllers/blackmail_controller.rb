class BlackmailController < ApplicationController
  before_filter :authenticate, :only => [:new, :create, :edit, :update]
  
  def index
    @blackmail = Blackmail.exposed
  end
   
  def view
    @blackmail = Blackmail.find params[:id]
    deny_access unless signed_in? && current_user.id == @blackmail.user_id or
      params[:victim_token] == @blackmail.victim_token
  end

  def show
    @user=User.find_by_remember_token(cookies[:remember_token])
  	@blackmail=@user.blackmail.all
    if @blackmail.empty?
      redirect_to new_blackmail_path
    end
  end
  
  def new
    @blackmail = Blackmail.new
    #probably don't even this this since we overwrite it in create
    @user_id = current_user.id
  end
  
  def create
    @blackmail = Blackmail.new params[:blackmail]
    @blackmail.user_id = current_user.id
    @blackmail.victim_token = OpenSSL::Digest::SHA512.new("#{Time.now}#{rand}").to_s
    #save demands (split the answer from the text box into multiple demands):
    params[:demands][:description] #or just [:demands?]
      .split("\n")
      .map(&:clean)
      .select { |s| not s.empty? }
      .each { |description| @blackmail.demands.new description: description }
    if @blackmail.save
      # Tell the UserMailer to send a blackmail email after save
      UserMailer.blackmail_email(@blackmail).deliver rescue nil
      
      #need to pass "@b_demands" to view after creation so view will know what your talking about
      render :view

    else
      # Re-render the blackmail page if problem occurs.
      render 'new' 
    end
  end
  
  def edit 
  	@blackmail=Blackmail.find_by_id(params[:id])
    @user_id = current_user.id
   	render 'edit'
  end
  
  def update
    #save blackmail
    @blackmail = Blackmail.find_by_id(params[:id])
    @blackmail.user_id = current_user.id
    if @blackmail.update_attributes(params[:blackmail])
      @blackmail.save
      flash[:success] = "Blackmail updated."
    else
      flash.now[:error] = 'Error occured when updating Blackmail'
    end

    @demands = Demand.find_by_blackmail_id(params[:id])
    if @demands.update_attributes(params[:demands])
      @demands.save
      flash[:success] = "Demands updated."
    else
      flash.now[:error] = 'Error occured when updating Demands'
    end
    redirect_to edit_blackmail_path @blackmail
  end

  def destroy
  end
  
  def image
   send_data Blackmail.find(params[:id]).image, type: 'image/jpeg', disposition: 'inline'
  end
  
private

    def authenticate
      deny_access unless signed_in?
    end
  
end
