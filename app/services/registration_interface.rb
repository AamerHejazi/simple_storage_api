module RegistrationInterface
    def register(email, password, password_confirmation)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end
  end
  