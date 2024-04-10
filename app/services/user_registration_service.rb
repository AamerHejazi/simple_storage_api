class UserRegistrationService
  include RegistrationInterface

  def register(email, password, password_confirmation)
    user = User.new(email: email, password: password, password_confirmation: password_confirmation)
    
    if user.save
      OpenStruct.new(success?: true, user: user)
    else
      OpenStruct.new(success?: false, errors: user.errors.full_messages)
    end
  end
end
