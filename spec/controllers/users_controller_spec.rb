require 'spec_helper'

describe UsersController do
  render_views
  
#------------------------------new user---------------------------------
describe "GET 'new'" do
  it "should be successful" do
    get :new
    response.should be_success
  end

  it "should have the right title" do
    get :new
    response.should have_content("h1", :content => "Sign up")
  end
end


#------------------------------create user---------------------------------
describe "POST 'create'" do

    describe "failure" do
      
      before(:each) do
        @attr = { :email => "", :password => "", :password_confirmation => "" }
      end
      
      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("h1", :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end
    end#end failure

    describe "success" do

      before(:each) do
        @attr = { :email => "user@example.com", :password => "foobar", :password_confirmation => "foobar" }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end
      
      it "should redirect to the homepage" do
        post :create, :user => @attr
        response.should redirect_to(root_path)
      end

      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
      
    end#end success
  end#end POST 'create'
#------------------------------sign-in user---------------------------------
describe "GET 'sign_in_form'" do

    it "should be successful" do
      get :sign_in_form
      response.should be_success
    end

    it "should have the right title" do
      get :sign_in_form
      response.should have_selector("h1", :content => "Sign in")
    end
  end #end "Get 'sign_in_form'

describe "POST 'sign_in'" do

    describe "invalid signin" do

      before(:each) do
        @attr = { :email => "email@example.com", :password => "invalid" }
      end

      it "should re-render the new page" do
        post :sign_in, :user => @attr
        response.should render_template('sign_in_form')
      end

      it "should have the right title" do
        post :sign_in, :user => @attr
        response.should have_selector("h1", :content => "Sign in")
      end
    end #end describe "invalid signin"

    describe "with valid email and password" do

      before(:each) do
        @user = Factory(:user)
        @attr = { :email => @user.email, :password => @user.password }
      end

      it "should sign the user in" do
        post :sign_in, :user => @attr
        controller.current_user.should == @user
        controller.should be_signed_in
      end

      it "should redirect to the root page" do
        post :sign_in, :user => @attr
        response.should redirect_to('blackmail#new')
      end
    end #end discribe 'with valid email...'

  end #end describe "POST"

#------------------------------sign-out user---------------------------------
describe "POST 'sign_out'" do

    it "should sign a user out" do
      test_sign_in(Factory(:user))
      post :sign_out
      controller.should_not be_signed_in
      response.should redirect_to(root_path)
    end
  end
#-----------------------------------------------------------------------
end#end describe UsersController