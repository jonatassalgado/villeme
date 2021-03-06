require 'rails_helper'

describe Invite, type: :model do

  let(:invite){ build(:invite) }

  describe 'validations' do
    subject{ invite }
    it{ is_expected.to be_valid }
  end

  describe "#new" do
    subject { invite }
    it{ is_expected.to have_attributes({email: 'user@gmail.com', name: 'John Doe', password: nil, key: 'qowiqmas01231ljadao' }) }
  end

  describe '#save' do
    subject { create(:invite) }

    it "does be true" do
      expect(subject).to be_truthy
    end
    it "does create a password" do
      expect(subject.password.length).to eq(8)
    end
  end

  describe '#geocoded_by_address' do
    it('should geocoded country') { expect(invite.country_code).to eq('US') }
    it('should geocoded state') { expect(invite.state_name).to eq('New York') }
    it('should geocoded city') { expect(invite.city_name).to eq('Albany') }
    it('should geocoded latitude') { expect(invite.latitude).to be_a_kind_of(Float) }
    it('should geocoded longitude') { expect(invite.longitude).to be_a_kind_of(Float) }
  end

  describe '#city' do
    it 'should return a city for invite' do
      city = create(:city, name: 'Albany')

      expect(invite.city).to eq(city)
    end
  end

end
