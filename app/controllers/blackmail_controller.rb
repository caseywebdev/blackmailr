class BlackmailController < ApplicationController

  def index
  end

  def show
  	#need to change id=1 to user_id
  	@user=User.find_by_id(1)
  	@blackmail=@user.blackmail.all
  end
  
  def new
    @blackmail = Blackmail.new
    #@user=User.new
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
  	@blackmail=Blackmail.find_by_id(params[:id])
  	render 'edit'
  end
  
  def update
  end

  def destroy
  end
  
end
