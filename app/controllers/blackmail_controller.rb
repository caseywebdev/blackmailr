class BlackmailController < ApplicationController

  def index
  end

  def show
  end
  
  def new
    #this isn't working, error: "Could not find table 'blackmail'" :'(
    @blackmail = Blackmail.new
  end
  
  def create
  end
  
  def edit
  end
  
  def update
  end

  def destroy
  end
  
end
