require 'bundler'
Bundler.require

require_relative 'config.rb'

get '/' do
  "Welcome to Montext"
end

get '/sms-reply' do
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message "Heyman"
  end
  twiml.text
end
