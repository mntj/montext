require 'bundler'
Bundler.require

require_relative 'config.rb'

get '/' do
  "Welcome to Montext!"
end

get '/inbound' do
  body = params["Body"]

  twiml = Twilio::TwiML::Response.new do |r|
    r.Message do |msg|
      msg.Body create_reply(body)
    end
  end
  twiml.text
end

def create_reply(input)
  i = input

  if i.strip.downcase == ""
    help_message
  else
    "Sorry! Didn't recognize that. " +
    help_message
  end
end

def help_message
  "Enter a stock symbol to get information about it. " <<
  "For example, 'GOOG'"
end
