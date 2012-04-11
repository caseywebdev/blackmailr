class UsersController < ApplicationController

  def show
  end
 
#create a new user (sign-up form)  
  def new
    @user = User.new
  end
  
#create a new user (sign-up processing)  
  def create
    #create a new user with all data received from form (in params)
    @user = User.new(params[:user])
    #once @user is defined properly, calling @user.save is all that’s needed to complete the registration
    if @user.save
        #Handle a successful save.
        flash[:success] = "Registration Successful!"
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
 
#displays the sign-in form
  def sign_in_form
     @user = User.new
  end
  
#post request goes to this action (from the form) to sign the user in  
  def sign_in
     #use the params given by sign_in_form to actually sign the user in
  end
  
#sign the user out (destroy the session/cookies)  
  def sign_out
  end
  
end
