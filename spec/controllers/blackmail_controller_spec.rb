require 'spec_helper'

describe BlackmailController do
  render_views
  
#------------------------------new blackmail---------------------------------
describe "GET 'new'" do
  it "should be successful" do
    get :new, :id => user.id
    response.should be_success
  end

  it "should have the right title" do
    get :new, :id => user.id
    response.should have_selector("h1", :content => "Create Blackmail")
  end
end

#------------------------------access control---------------------------------
  describe "access control" do
    it "should deny access to 'create'" do
      post :create
      response.should redirect_to(signin_path)
    end
    
    it "should deny access to 'new'" do
      get :new, :id => user.id
      response.should redirect_to(signin_path)
    end
  end

#------------------------------create blackmail---------------------------------  
describe "POST 'create'" do
    
    before(:each) do
      @user = test_sign_in(Factory(:user))
    end

    describe "failure" do

      before(:each) do
        @attr = { :title             => "",
                  :description       => "",
                  :victim_name       => "",
                  :victim_email      => "",
                  :expired_at        => "" }
      end

      it "should not create a blackmail" do
        lambda do
          post :create, :blackmail => @attr
        end.should_not change(Blackmail, :count)
      end
      
      it "should re-render the home page" do
        post :create, :blackmail => @attr
        response.should render_template('new')
      end
    end

    describe "success" do
      
      before(:each) do
        @attr = { :title             => "I saw that...",
                  :description       => "I saw you that one day",
                  :victim_name       => "Bill Moulden",
                  :victim_email      => "supImBill@hotmail.com",
                  :expired_at        => "2012-06-30 22:18:00" }
      end
      
      it "should create a blackmail" do
        lambda do
          post :create, :blackmail => @attr,  :user_id => user.id
        end.should change(Blackmail, :count).by(1)
      end
      
      it "should redirect to view blackmail" do
        post :create, :blackmail => @attr,  :user_id => user.id
        response.should render_template('view')
      end
    end
  end  
#-----------------------------------------------------------------------
end #end describe BlackmailController