module UsersHelper
  def sign_in_cookies(user)
      cookies.permanent.signed[:remember_token] = [user.id]
      #self.current_user = user
  end
end