class BlackmailController < ApplicationController
  before_filter :authenticate, :only => [:new, :create, :edit, :update]
  
  def index
  end

  def view
    @blackmail=Blackmail.find_by_id(params[:id])
    render 'view'
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
    #probably don't even this this since we overwrite it in create
    @user_id = current_user.id
  end
  
  def create
    @blackmail = Blackmail.new params[:blackmail]
    @blackmail.user_id = current_user.id
    #save demands (split the answer from the text box into multiple demands):
      params[:demands][:description] #or just [:demands?]
        .split("\n")
        .map(&:clean)
        .select { |s| not s.empty? }
        .each { |description| @blackmail.demands.new description: description }
    if @blackmail.save
      puts "**************HELLO????"
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
      redirect_to :root

    else
      # Re-render the blackmail page if problem occurs.
      render 'new' 
    end
  end
  
  def edit 
  	@blackmail=Blackmail.find_by_id(params[:id])
    dm = @blackmail.demands        
    @line = []    
    dm.each do |d|
      @line.push(d[:description].to_s)
    end
    @line.join("\n")
    puts @line
   	render 'edit'
  end
  
  def update
    @blackmail = Blackmail.find_by_id(params[:id])
    if @blackmail.update_attributes(params[:blackmail])
      @blackmail.user_id = current_user.id
      @blackmail.save
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
