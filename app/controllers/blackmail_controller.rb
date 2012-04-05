class BlackmailController < ApplicationController

  def index
  end

  def show
  end
  
  def new
    @blackmail = Blackmail.new
  end
  
  def create
    #create a new blackmail with all data received from form (in params)
    @blackmail = Blackmail.new(params[:blackmail])
    #once @blackmail is defined properly, calling @blackmail.save is all that’s needed to complete
    if @blackmail.save
        #Handle a successful save.
        flash[:success] = "Blackmail created!"
        redirect_to root_path
    else
    #re-render the signup page if invalid signup data is received.
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
