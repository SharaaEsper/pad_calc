#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'
Dir[File.dirname(__FILE__) + '/include/*.rb'].each {|file| require file }
class Calc_app < Sinatra::Base

	set :environment, :production
	get '/' do
		redirect '/lookup'
	end

	get '/lookup' do
		erb :lookup
	end


	get '/lookup/:username' do
		@status,@end_result,@total_mp = Pad_calc.lookup( params[:username] )
		if @status != "okay"
			erb :error
		else
			erb :lookupreturn
		end
	end
end
