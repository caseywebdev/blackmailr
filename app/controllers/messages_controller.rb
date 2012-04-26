class MessagesController < ApplicationController

  def create
    message = Message.new params[:message]
    message.blackmail_id = params[:blackmail_id]
    message.from_victim = !signed_in?
    message.save
    redirect_to Blackmail.find(message.blackmail_id).victim_view_url
  end

end