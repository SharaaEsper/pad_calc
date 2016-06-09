#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'mechanize'
require 'json'

module Pad_calc
	def Pad_calc.lookup( username, filters )

		#Initialize Junk
		user = username
		agent = Mechanize.new
		end_result = Array.new
		stuff_on_team = Array.new
		mp = 0
		total_mp = 0
		total_mp_shown = 0
		f = File.read("include/mapping.json")
		mp_mapping = JSON.parse(f)
		#Grab some JSON from padherder
		begin
			buffer = open("https://www.padherder.com/user-api/user/#{user}").read
		rescue OpenURI::HTTPError
			return "NoSuchUser", nil, nil, nil
		end
		#puts open("https://www.padherder.com/user-api/user/#{user}").read
		user_json = JSON.parse(buffer)
		buffer = open("https://www.padherder.com/api/monsters").read
		monster_json = JSON.parse(buffer)
		#Make it faster
		monster_hash = Hash[monster_json.map {|foo| [foo["id"], foo]}]

		#Build initial hash
		user_json["monsters"].each do |monster|
			#Grab Monster ID, Name and MP value
			mid = monster["monster"]
			name = monster_hash[mid]["name"]
			#If it has a pdx_id we should use that instead
			if monster_hash[mid].has_key? "pdx_id"
				mp = mp_mapping[monster_hash[mid]["pdx_id"].to_s]
			else
				mp = mp_mapping["#{mid}"]
			end
			total_mp += mp
			end_result << { :name => name, :mp => mp, :id => monster["id"], :priority => monster["priority"] }
		end

		#Grab the ids of shit on teams
		
		user_json["teams"].each do |team|
			stuff_on_team << team["leader"] 
			stuff_on_team << team["sub1"] 
			stuff_on_team << team["sub2"] 
			stuff_on_team << team["sub3"] 
			stuff_on_team << team["sub4"] 
		end

		#Apply filters
		filters.each do |filter|
			if filter == "no1mp=True"
				end_result.delete_if {|arr| arr[:mp] == 1}
			elsif filter == "no5mp=True"
				end_result.delete_if {|arr| arr[:mp] == 5}
			elsif filter == "no10mp=True"
				end_result.delete_if {|arr| arr[:mp] == 10}
			elsif filter == "noonteam=True"
				end_result.delete_if {|arr| stuff_on_team.include?(arr[:id])}	
			elsif filter == "noprio0=True"
				end_result.delete_if {|arr| arr[:priority] == 0}
			elsif filter == "noprio1=True"
				end_result.delete_if {|arr| arr[:priority] == 1}
			elsif filter == "noprio2=True"
				end_result.delete_if {|arr| arr[:priority] == 2}
			elsif filter == "noprio3=True"
				end_result.delete_if {|arr| arr[:priority] == 3}
			end
		end

		#Tally up filtered MP
		end_result.each do |hsh|
			total_mp_shown += hsh[:mp]
		end


		status = "okay"
		return status,end_result, total_mp, total_mp_shown
	end
end

