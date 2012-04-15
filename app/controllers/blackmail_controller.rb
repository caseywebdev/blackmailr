class BlackmailController < ApplicationController

  def index
  end

  def show
  end
  
  def new
    @blackmail = Blackmail.new
  end
  
  def create
    @blackmail = Blackmail.new params[:blackmail]
    params[:demands]
      .split("\n")
      .map(&:clean)
      .filter { |s| not s.empty? }
      .each { |description| @blackmail.demands.build description: description }
    if @blackmail.save
      #upload image:
            #get the picture from the form
            upload = params[:img_location]
            #TODO: will need to change the name to be id_1.jpg, id_2.jpg...
            name =  upload.original_filename
            #TODO: will need to change this to assets/images 
            directory = "public/images"
            # create the file path
            path = File.join(directory, name)
            # write the file
            File.open(path, "wb") { |f| f.write(upload.read) }
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
  end
  
  def update
  end

  def destroy
  end
  
end
