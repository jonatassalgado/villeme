require 'rails_helper'

describe Event, type: :model do

  before(:all) do
    I18n.locale = :en
  end

  let(:event){ build(:event) }

  describe 'associations' do
    it { is_expected.to belong_to :place }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :price }
    it { is_expected.to have_and_belong_to_many :subcategories }
    it { is_expected.to have_and_belong_to_many :personas }
    it { is_expected.to have_and_belong_to_many :categories }
    it { is_expected.to have_and_belong_to_many :weeks }
    it { is_expected.to have_many :agendas }
    it { is_expected.to have_many :agended_by }
    it { is_expected.to have_many :tips }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe '.all_persona_in_my_city' do
    it 'should return 3 events from user persona' do
      persona = build(:persona)
                build(:persona, name: 'Fashionist')

      3.times do
        event = create(:event, name: Faker::Lorem.sentence(2, false, 4))
                event.personas << persona
      end
      create(:event)

      user = create(:user)
             user.personas << persona
             allow(user).to receive(:city).and_return create(:city)

      expect(Event.all_persona_in_city(user.personas_name, user.city, upcoming: false).count).to eq(3)
    end
  end

  describe '.all_categories_in_city' do
    context 'when categories params it is capitalize' do
      it 'should return 2 events from leisure and art categories' do
        categories = [build(:category), build(:category, name: 'Art', slug: 'art')]

        2.times do
          event = FactoryGirl.create(:event, name: Faker::Lorem.sentence(2, false, 4))
          event.categories << categories
        end
        create(:event)

        city = create(:city)
               allow(city).to receive(:items).and_return(Event.all)

        expect(Event.all_categories_in_city(['Leisure', 'Art'], city, upcoming: false).count).to eq(2)
      end
    end

    context 'when categories params it is downcase' do
      it 'should return 2 events from leisure and art categories' do
        categories = [build(:category), build(:category, name: 'Art', slug: 'art')]

        2.times do
          event = FactoryGirl.create(:event, name: Faker::Lorem.sentence(2, false, 4))
          event.categories << categories
        end
        create(:event)

        city = create(:city)
               allow(city).to receive(:items).and_return(Event.all)

        expect(Event.all_categories_in_city(['leisure', 'art'], city, upcoming: false).count).to eq(2)
      end
    end
  end

  describe '.all_in_neighborhood' do
    it 'should return 3 events' do
      3.times do
        event = create(:event, neighborhood_name: 'Pine Hills', address: '502 Washington Avenue, Albany, NY 12203, USA', name: Faker::Lorem.sentence(2, false, 4))
      end
      create(:event, neighborhood_name: 'Partenon', address: 'Rua Rivadavia Correia, 08 - Partenon')
      user = build(:user, neighborhood_name: 'Pine Hills')
             allow(user).to receive(:neighborhood).and_return build(:neighborhood, name: 'Pine Hills')

      expect(Event.all_in_neighborhood(user.neighborhood_name, upcoming: false).count).to eq(3)
    end
  end

  describe '.all_fun_in_city' do
    it 'should return 2 events' do
      categories = [build(:category, slug: 'leisure'), build(:category, slug: 'culture')]

      2.times do
        event = create(:event, city_name: 'Albany', name: Faker::Lorem.sentence(2, false, 4))
                event.categories = categories
      end

      create(:event, city_name: 'Albany')

      user = build(:user, city_name: 'Albany')
             allow(user).to receive(:city).and_return build(:city, name: 'Albany')


      expect(Event.all_fun_in_city(user.city, upcoming: false).count).to eq(2)
    end

    context 'when events is out of month range of upcoming scope' do
      it 'should return 1 event' do
        categories = [build(:category, slug: 'leisure'), build(:category, slug: 'culture')]

        2.times do
          event = create(:event, city_name: 'Albany', name: Faker::Lorem.sentence(2, false, 4))
          event.categories = categories
        end

        event_in_range = create(:event, city_name: 'Albany', date_start: Date.current, date_finish: Date.current + 7)
                         event_in_range.categories = categories

        user = build(:user, city_name: 'Albany')
               allow(user).to receive(:city).and_return build(:city, name: 'Albany')

        expect(Event.all_fun_in_city(user.city).upcoming.count).to eq(1)
      end
    end
  end

  describe '.all_education_in_city' do
    it 'should return 2 events' do
      categories = [build(:category, slug: 'education')]

      2.times do
        event = create(:event, city_name: 'Albany', name: Faker::Lorem.sentence(2, false, 4))
        event.categories = categories
      end

      create(:event, city_name: 'Albany')

      user = build(:user, city_name: 'Albany')
      allow(user).to receive(:city).and_return build(:city, name: 'Albany')


      expect(Event.all_education_in_city(user.city).count).to eq(2)
    end
  end

  describe '.all_health_in_city' do
    it 'should return 2 events' do
      categories = [build(:category, slug: 'sport'), build(:category, slug: 'health')]

      2.times do
        event = create(:event, city_name: 'Albany', name: Faker::Lorem.sentence(2, false, 4))
        event.categories = categories
      end

      create(:event, city_name: 'Albany')

      user = build(:user, city_name: 'Albany')
      allow(user).to receive(:city).and_return build(:city, name: 'Albany')


      expect(Event.all_health_in_city(user.city).count).to eq(2)
    end
  end

  describe '.all_trends_in_city' do
    it 'should return 2 events' do
      2.times do
        event = create(:event, city_name: 'Albany', name: Faker::Lorem.sentence(2, false, 4))
        2.times { event.agendas.create }
      end

      other_event = create(:event, city_name: 'Albany')
                    other_event.agendas.create

      user = build(:user, city_name: 'Albany')
      allow(user).to receive(:city).and_return build(:city, name: 'Albany')

      expect(Event.all_trends_in_city(user.city).count).to eq(2)
    end
  end

  describe '#create' do

    context 'event valid' do
      it 'should create event' do
        event = create(:event)

        event.save

        expect(event).to be_valid
      end
    end

    context 'event invalid' do
      it 'should NOT create event' do
        event = Event.new

        event.save

        expect(event).to_not be_valid
      end
    end

  end

  describe '.geocoded_by_address' do
    context 'when address is complete' do
      it('should geocoded country') { expect(event.country_code).to eq('US') }
      it('should geocoded state') { expect(event.state_name).to eq('New York') }
      it('should geocoded city') { expect(event.city_name).to eq('Albany') }
      it('should geocoded latitude') { expect(event.latitude).to be_a_kind_of(Float) }
      it('should geocoded longitude') { expect(event.longitude).to be_a_kind_of(Float) }
    end
  end

  describe '#country' do
    it 'should return country of event' do
      create(:country, name: 'United States')
      create(:country, name: 'Brazil')

      expect(event.country.name).to eq('United States')
    end
  end

  describe '#state' do
    it 'should return state of event' do
      create(:state, name: 'New York')
      create(:state, name: 'Florida')

      expect(event.state.name).to eq('New York')
    end
  end

  describe '#city' do
    it 'should return city of event' do
      create(:city, name: 'Albany')
      create(:city, name: 'Rio de Janeiro')

      expect(event.city.name).to eq('Albany')
    end
  end

  describe '#neighborhood' do
    it 'should return neighborhood of event' do
      create(:neighborhood, name: 'Pine Hills')
      create(:neighborhood, name: 'Bronx')

      expect(event.neighborhood.name).to eq('Pine Hills')
    end
  end

  describe '#place' do
    it 'should return a place from event' do
      create(:place, name: 'New York State Museum')
      create(:place, name: 'Cristo Redentor')

      expect(event.place.name).to eq('New York State Museum')
    end
  end

  describe '#name_with_limit' do
    it 'should return name of event with limit of chars' do
      event = create(:event, name: 'This name of events have more than 45 chars for make this test testable')

      expect(event.name_with_limit.length).to eq(49)
    end
  end

  describe '#description_whit_limit' do
    it 'should return description of event with limit of chars' do
      event = create(:event, description: 'This description of events have more than 70 chars for make this test testable testable')

      expect(event.description_with_limit.length).to eq(90)
    end
  end

  describe '#relative_latitude' do
    it 'should return the latitude from event' do
      expect(event.relative_latitude.to_s).to start_with('42.663')
    end
  end

  describe '#relative_longitude' do
    it 'should return the longitude from event' do
      expect(event.relative_longitude.to_s).to start_with('-73.774')
    end
  end

  describe '#price' do
    context 'when event have a price' do
      it 'should return price of event' do
        expect(event.price[:value]).to eq('12.00')
      end
    end
    context 'when event DO NOT have a price' do
      it 'should return a string' do
        event = create(:event, cost: 0)

        expect(event.price[:value]).to eq('0.00')
      end
    end
  end

  describe '#period_that_occurs' do
    it 'should return a period that event occurs' do

      expect(event.period_that_occurs).to eq('17/11 - 28/11')
    end
  end

  describe '#agended_by_count' do
    it 'should return the number of 0 people which scheduled event' do
      allow(event).to receive_message_chain(:agended_by, :count).and_return(0)

      expect(event.agended_by_count).to eq({valid: false, count: ""})
    end

    it 'should return the number of 1 person which scheduled event' do
      allow(event).to receive_message_chain(:agended_by, :count).and_return(1)

      expect(event.agended_by_count).to eq({valid: true, count: 1, text: '1 pessoa agendou'})
    end

    it 'should return the number of 5 people which scheduled event' do
      allow(event).to receive_message_chain(:agended_by, :count).and_return(5)

      expect(event.agended_by_count).to eq({valid: true, count: 5, text: "5 pessoas agendaram"})
    end
  end

  describe '#day_of_week' do
    it 'should return Today which event occur' do
      Timecop.freeze(2014, 11, 17)
      allow(event).to receive(:weeks).and_return([double(binary: 1)])

      expect(event.day_of_week).to eq('Today')
    end

    it 'should return Tomorrow which event occur' do
      Timecop.freeze(2014, 11, 17)
      allow(event).to receive(:weeks).and_return([double(binary: 2)])

      expect(event.day_of_week).to eq('Tomorrow')
    end

    it 'should return Saturday which event occur' do
      Timecop.freeze(2014, 11, 17)
      allow(event).to receive(:weeks).and_return([double(binary: 6)])

      expect(event.day_of_week).to eq('Saturday')
    end

    it 'should return the date 17/Nov which event occur' do
      Timecop.freeze(2014, 11, 10)
      allow(event).to receive(:weeks).and_return([double(binary: 1)])

      expect(event.day_of_week).to eq('17/Nov')
    end

    # it 'should return the date 21/Nov which event occur' do
    #   Timecop.freeze(2014, 11, 10)
    #   allow(event).to receive(:weeks).and_return([double(binary: 5)])
    #
    #   expect(event.day_of_week).to eq('21/Nov')
    # end

    after(:each) do
      Timecop.return
    end
  end

  describe '#today?' do
    it 'should return TRUE' do
      Timecop.freeze(2014, 11, 17)
      allow(event).to receive(:weeks).and_return([double(binary: 1)])

      expect(event.today?).to be_truthy
    end

    it 'should return FALSE' do
      Timecop.freeze(2014, 11, 18)
      allow(event).to receive(:weeks).and_return([double(binary: 1)])

      expect(event.today?).to be_falsey
    end

    after(:each) do
      Timecop.return
    end
  end

  describe '#start_hour' do
    context 'when event has a NOT rounded hour' do
      it 'should return the hour of event start NOT formatted' do
        event = build(:event, hour_start_first: Time.utc(2015, 'may',1,20,15,1))

        expect(event.start_hour).to eq('20:15h')
      end
    end

    context 'when event has a rounded hour' do
      it 'should return the hour of event start formatted' do
        event = build(:event, hour_start_first: Time.utc(2015, 'may',1,20,00,1))

        expect(event.start_hour).to eq('20h')
      end
    end

    context 'when event during all day' do
      it 'should return the hour of event start formatted' do
        event = build(:event, allday: true)

        expect(event.start_hour).to eq('AM-PM')
      end
    end
  end

  describe '#days_of_week' do
    it 'should return a days of week formatted' do
      Timecop.freeze(2014, 11, 17)
      monday = double(id: 1, name: 'Monday', slug: 'monday')
      allow(event).to receive_message_chain(:weeks, :select).and_return([monday])
      double(Week, id: 1, name: 'Monday', slug: 'monday')
      allow(Week).to receive_message_chain(:select, :includes).and_return([monday])

      expect(event.days_of_week).to eq("<span class='label white-bg border'>Monday</span>")
    end

    after(:each) do
      Timecop.return
    end
  end

end
