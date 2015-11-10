#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'mechanize'
require 'json'

module Pad_calc
	def Pad_calc.lookup( params )

		#Initialize Junk
		user = params
		agent = Mechanize.new
		end_result = Array.new
		mp = 0
		total_mp = 0
		f = File.read("include/mapping.json")
		mp_mapping = JSON.parse(f)
		#Grab some JSON from padherder
		begin
			buffer = open("https://www.padherder.com/user-api/user/#{user}").read
		rescue OpenURI::HTTPError
			return "NoSuchUser", nil, nil
		end
		puts open("https://www.padherder.com/user-api/user/#{user}").read
		user_json = JSON.parse(buffer)
		buffer = open("https://www.padherder.com/api/monsters").read
		monster_json = JSON.parse(buffer)
		#Make it faster
		monster_hash = Hash[monster_json.map {|foo| [foo["id"], foo]}]

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
			end_result << { :name => name, :mp => mp }
		end
		status = "okay"
		return status,end_result, total_mp
	end
end


		


