#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
Dir[File.dirname(__FILE__) + '/include/*.rb'].each {|file| require file }

set :environment, :production


get '/' do
	redirect '/lookup'
end

get '/lookup' do
	erb :lookup
end


get '/lookup/:username' do
	@end_result,@total_mp = Pad_calc.lookup( params[:username] )
	erb :lookupreturn
end

get '/hi' do
	"Hello World!"
end

