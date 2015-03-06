require 'camping'
require 'mongoid'
require 'json'

Camping.goes :ScoutingApi

module Scouting
	def self.create
		mongoid.load! 'mongoid.yml'
	end

	module Controllers
		class Teams
			def get
#				@teams = Team.count > 0 ? Team.all.asc( :_id ) : nil
				@body = "a string" #@teams.to_json
			end
		end
	end
end
