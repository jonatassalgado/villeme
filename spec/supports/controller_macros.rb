module ControllerMacros
  def set_admin_logged_in(admin_attributes={})
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:admin, admin_attributes)
    allow(controller).to receive(:current_user) { @user }
    sign_in @user
  end

  def set_user_logged_in(user_attributes={})
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, user_attributes)
    allow(controller).to receive(:current_user) { @user }
    sign_in @user
  end

  def set_user_logged_in_not_invited
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = create(:user, invited: false)
    sign_in @user
  end

  def set_current_user_nil
    allow(controller).to receive(:current_user).and_return(nil)
  end


end
