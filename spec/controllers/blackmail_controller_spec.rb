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
#-----------------------------------------------------------------------
end #end describe BlackmailController