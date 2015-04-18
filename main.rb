require 'bundler'
Bundler.require

require_relative 'config.rb'

enable :sessions

get '/' do
  "Welcome to Montext!"
end

get '/inbound' do
  session["count"] ||= 0
  body = params["Body"]

  twiml = Twilio::TwiML::Response.new do |r|
    r.Message do |msg|
      msg.Body create_reply(body)
    end
  end

  session["count"] += 1
  twiml.text
end

def create_reply(input)
  if session["count"] == 0
    new_message << help_message
  elsif input.strip.downcase == "commands"
    help_message
  else
    error_message << help_message
  end
end

def new_message
  "Welcome to Montext! "
end

def help_message
  "Enter a stock symbol to get information about it. " <<
  "For example, 'GOOG'"
end

def error_message
  "Sorry! Didn't recognize that. "
end
