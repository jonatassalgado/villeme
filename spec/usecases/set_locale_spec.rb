require 'rails_helper'
require_relative '../../app/domain/usecases/users/set_locale'

describe 'UseCases::SetLocale' do

  describe '#set_locale' do

    context 'when @user have a :locale' do
      before(:each) do
        @user = double('User', locale: :br)
        I18n.locale = :en
      end

      subject{ Villeme::UseCases::SetLocale.new(@user).set_locale }

      it 'should settable I18n.locale = @user.locale' do
        Villeme::UseCases::SetLocale.new(@user).set_locale
        expect(I18n.locale).to eq(@user.locale)
      end

      it 'should return true if settable is successful' do
        is_expected.to be_truthy
      end
    end

    context 'when @user DO NOT have :locale and controller have :locale parameter' do
      before(:each) do
        @user = double('User', locale: nil)
        @params = {locale: :fr}
        I18n.locale = :en
      end

      subject{ Villeme::UseCases::SetLocale.new(@user).set_locale(@params) }

      it 'should i18n.locale settable equal parameter' do
        Villeme::UseCases::SetLocale.new(@user).set_locale(@params)
        expect(I18n.locale).to eq(:fr)
      end

      it 'should return true if settable is successful' do
        is_expected.to be_truthy
      end
    end

    context 'when @user DO NOT have a :locale, controller DO NOT have :locale parameter AND @user have an ip' do
      before(:each) do
        @user = double('User', locale: nil, ip: '177.18.147.47')
        @params = nil
        I18n.locale = :en
      end

      it 'should return country_code from Geocoder using @user ip' do
        Villeme::UseCases::SetLocale.new(@user).set_locale(@params)
        expect(I18n.locale).to eq(:br)
      end
    end

  end

end