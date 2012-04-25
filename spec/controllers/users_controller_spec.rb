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
    response.should have_selector("h1", :content => "Sign up")
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

#-----------------------------------------------------------------------
end#end describe UsersController