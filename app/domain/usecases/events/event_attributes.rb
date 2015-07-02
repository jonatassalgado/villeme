module Villeme
  module UseCases
    class EventAttributes
      class << self

        def name_with_limit(entity)
          name = entity.name

          if name.length > 45
            "#{name[0..45]}..."
          else
            name
          end
        end


        def description_with_limit(entity)

          return nil if entity.description.nil?

          name = entity.name
          description = ActionController::Base.helpers.strip_tags(entity.description)
          if name.length > 25
            "#{description[0..70]}..."
          else
            "#{description[0..100]}..."
          end
        end


        def price(entity)
          if entity.cost == 0 or entity.cost.blank?
            I18n.t('event.free')
          else
            ActionController::Base.helpers.number_to_currency(entity.cost, locale: I18n.locale)
          end
        end



        def period_that_occurs(entity)
          "#{entity.date_start.strftime("%d/%m")} - #{entity.date_finish.strftime("%d/%m")}"
        end


      end
    end
  end
end