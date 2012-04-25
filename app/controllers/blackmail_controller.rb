class BlackmailController < ApplicationController
  before_filter :authenticate, :only => [:new, :create, :edit, :update]
  
  def index
    @blackmails = Blackmail.exposed
  end
   
  def view
    @blackmail=Blackmail.find_by_id(params[:id])
    @b_demands = @blackmail.demands        
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
    @blackmail.victim_token = OpenSSL::Digest::SHA512.new("#{Time.now}#{rand}").base64digest
    #save demands (split the answer from the text box into multiple demands):
      params[:demands][:description] #or just [:demands?]
        .split("\n")
        .map(&:clean)
        .select { |s| not s.empty? }
        .each { |description| @blackmail.demands.new description: description }
    if @blackmail.save
      #upload image:
          5.times do|i|
                @temp_string = "images_#{i}"
                puts @temp_string
                if(params[:"#{@temp_string}"])
                    #get the picture from the form
                    upload = params[:"#{@temp_string}"]
                    name =  "#{@blackmail.id}_#{i}.jpg"
                    directory = "#{Rails.root}/app/assets/images/blackmail"
                    # create the file path
                    path = File.join(directory, name)
                    # write the file
                    File.open(path, 'wb') { |f| f.write upload.read }
                    #TODO: resize with rmagic before save
                 end
           end
      # Tell the UserMailer to send a blackmail email after save
      UserMailer.blackmail_email(@blackmail).deliver
      
      #need to pass "@b_demands" to view after creation so view will know what your talking about
      @b_demands = @blackmail.demands
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
      render 'edit'
    end
    
#/* what I know:
# * @b_demands = [#<Demand id: 1, blackmail_id: 1, description: "three", completed: false, updated_at: "2012-04-18 22:58:42">, #<Demand id: 2, blackmail_id: 1, description: "two", completed: false, updated_at: "2012-04-18 21:29:40">, #<Demand id: 3, blackmail_id: 1, description: "three", completed: false, updated_at: "2012-04-18 21:29:40">]
# * @b_demands[1] =  #<Demand id: 2, blackmail_id: 1, description: "two", completed: false, updated_at: "2012-04-18 21:29:40">
# * @b_demands[1].description = "two"
# * demands descriptions currently being display (in edit.html.haml) as id="demands_[1].description" name="demands[[1].description]"
# */  
 
    #TODO: do I need to do something special to loop through the multiple demands checkboxes?
    #save demands
    @demands = Demand.find_by_blackmail_id(params[:id])
    if @demands.update_attributes(params[:demands])
      @demands.save
      flash[:success] = "Demands updated."
      redirect_to :home
    else
      flash.now[:error] = 'Error occured when updating Demands'
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
