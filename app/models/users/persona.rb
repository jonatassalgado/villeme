class Persona < ActiveRecord::Base

	# Globalize
	translates :name, fallbacks_for_empty_translations: true

	# associações
	has_and_belongs_to_many :users
	has_and_belongs_to_many :items
	has_and_belongs_to_many :invites

	def self.get_user_personas(user)
		if user.personas.size > 1
			user.personas.first
		else
			user.personas.first
		end
	end

	def self.get_names(personas)
		personas.joins(:translations).pluck('persona_translations.name')
	end

	def self.to_query(personas)
		"persona=#{personas.joins(:translations).pluck('persona_translations.name').join('+')}"
	end

	def self.query_to_array(personas_query)
		personas_query ? personas_query.split('+') : []
	end

end
