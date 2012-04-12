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
        #sign_in @user #after a new user signs up, log them in
        flash[:success] = "Registration Successful!"
        redirect_to root_path
    else
    #re-render the signup page if invalid signup data is received.
      render 'new'
    end
  end

#TODO  
#users "profile"
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

#TODO (currently the sign in form is trying to insert?)
#post request goes to this action (from the form) to sign the user in  
  def sign_in
     #use the params given by sign_in_form to actually sign the user in
    User.find_by_email(params[:session][:email]).try(:authenticate, params[:session][:password])
    if user.nil?
      flash.now[:error] = "Invalid email/password combination."
      render 'sign_in_form'
    else
      #sign_in user
      redirect_to user
    end
  end
  
#TODO  
#sign the user out (destroy the session/cookies)  
  def sign_out
  end
  
end
