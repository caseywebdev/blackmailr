class MessagesController < ApplicationController

  def create
    message = Message.new params[:message]
    message.blackmail_id = params[:blackmail_id]
    message.from_victim = !signed_in?
    message.save
    redirect_to view_path message.blackmail_id
  end

end