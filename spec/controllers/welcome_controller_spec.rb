require 'rails_helper'

describe WelcomeController, type: :controller do

  describe 'GET #index' do

    context 'current_user.signed_in? == TRUE' do
      before(:each) do
        set_user_logged_in
        allow(@user).to receive(:city_slug).and_return(:albany)
        allow(controller).to receive(:current_user) { @user }
      end
      it 'should redirected to root' do
        get :index, locale: :en

        expect(response).to redirect_to(root_path)
      end
    end

    context 'current_user.signed_in? == FALSE' do
      before(:each) do
        set_current_user_nil
      end

      it 'should load page with success' do
        get :index, locale: :en

        expect(response).to have_http_status(:success)
      end
    end

    context 'when params[:key]' do
      context 'when current_user.signed_in? == FALSE' do
        it 'should redirect to sign in' do
          set_current_user_nil
          invited_user = build(:user, email: 'test@gmail.com')
          allow(User).to receive(:find_by) { invited_user }
          invite = build(:invite, email: 'test@gmail.com')
          allow(Invite).to receive(:find_by) { invite }

          get :index, key: invite.key

          expect(response).to redirect_to sign_in_path
        end
        it 'does invite.password == user.password' do
          set_current_user_nil
          invite = create(:invite, email: 'test@gmail.com')
          allow(Invite).to receive(:find_by) { invite }

          get :index, key: invite.key

          expect(User.find_by(email: 'test@gmail.com').valid_password? invite.password).to eq(true)
        end
      end
      context 'when current_user.signed_in? == TRUE' do
        it 'should redirect to newsfeed' do
          set_user_logged_in
          invited_user = build(:user, email: 'test@gmail.com')
          allow(User).to receive(:find_by) { invited_user }
          invite = build(:invite, email: 'test@gmail.com')

          get :index, key: invite.key

          expect(response).to redirect_to root_path
        end
      end
      context 'when params[:key].valid? == FALSE' do
        context 'signed_in? FALSE' do
          it 'should redirect to welcome page' do
            set_current_user_nil
            invalid_invite = build(:invite, key: '987654321')

            get :index, key: 'keyn0texisted'

            expect(response).to redirect_to welcome_path
          end
        end
      end
    end

  end
end
