module RequestHelpers
    def login_user_and_get_token(user)
        
        auth_token = user.auth_tokens.create!
        auth_token.token 
      end
  end