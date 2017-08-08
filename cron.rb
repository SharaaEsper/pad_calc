#!/usr/bin/env ruby

require 'fileutils'
require 'rubygems'
require 'open-uri'
require 'mechanize'
require 'json'

#Reparse MP mapping by scraping padx. Run in a cronjob. 



agent = Mechanize.new
mapping = Hash.new


mid = 0
buffer = open("https://www.padherder.com/api/monsters").read
monster_json = JSON.parse(buffer)
monster_json.each do |foo|
#Check if it has a pdx_id we should be mapping to instead
	if foo.has_key? "pdx_id"
		mid = foo["pdx_id"]
	else
		mid = foo["id"]
	end
	mp = foo["monster_points"] 
	puts "Processing: #{mid} \r"	
	mapping[mid.to_i] = mp.to_i
end

f =File.open("include/mapping.json.tmp", "w")
f.write(mapping.to_json)
f.close

FileUtils.rm("#{File.dirname(__FILE__)}/include/mapping.json.bk", :force => true)
FileUtils.mv("#{File.dirname(__FILE__)}/include/mapping.json", "#{File.dirname(__FILE__)}/include/mapping.json.bk")
FileUtils.mv("#{File.dirname(__FILE__)}/include/mapping.json.tmp", "#{File.dirname(__FILE__)}/include/mapping.json")

