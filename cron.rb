#!/usr/bin/env ruby

require 'fileutils'
require 'rubygems'
require 'open-uri'
require 'mechanize'
require 'json'

#Reparse MP mapping by scraping padx. Run in a cronjob. 



agent = Mechanize.new
mapping = Hash.new

    buffer = open("https://www.padherder.com/api/monsters").read
    monster_json = JSON.parse(buffer)
		monster_json.each do |foo|
			mid = foo["id"]
      page = agent.get("http://puzzledragonx.com/en/monster.asp?n=#{mid}")
        arr =  page.search('//table[@class = "tableprofile"]/tr/td[@class = "data"]')
        mp = arr[-1].to_s.scan(/>(.*)</)[0][0].to_i
        if mp == 0
                mp = arr[-2].to_s.scan(/>(.*)</)[0][0].to_i
                if mp == 0
                mp = arr[-3].to_s.scan(/>(.*)</)[0][0].to_i
                end
        end
		
			mapping[mid.to_i] = mp.to_i
end

f =File.open("include/mapping.json.tmp", "w")
	f.write(mapping.to_json)
f.close

FileUtils.rm('include/mapping.json.bk')
FileUtils.mv('include/mapping.json', 'include/mapping.json.bk')
FileUtils.mv('include/mapping.json.tmp', 'include/mapping.json')

