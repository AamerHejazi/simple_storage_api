class UserRegistrationService
  include RegistrationInterface

  def register(user_params)
    user = User.new(user_params)
    
    if user.save
      OpenStruct.new(success?: true, user: user)
    else
      OpenStruct.new(success?: false, errors: user.errors.full_messages)
    end
  end
end
