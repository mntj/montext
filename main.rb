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
  r = data_response(exchange: "XNAS", ticker: input)

  if successful?(r)
    "Name --- #{r["Security"]["Name"]}\n" <<
    "Ask  --- #{r["Ask"]}\n" <<
    "High --- #{r["High"]}\n" <<
    "Low  --- #{r["Low"]}"
  elsif session["count"] == 0
    new_message << help_message
  elsif r["Message"]
    r["Message"]
  elsif input.strip.downcase == "commands"
    help_message
  else
    error_message << help_message
  end
end

def successful?(response)
  !response["Outcome"].include? "Error"
end

def new_message
  "Welcome to Montext! "
end

def help_message
  "Enter a stock symbol to get information about it. "
end

def error_message
  "Sorry! Didn't recognize that. "
end

def data_response(exchange:, ticker:)
  uri = XIGNITE_BASE_URL + ticker + "." + exchange
  HTTParty.get(uri)
end

XIGNITE_BASE_URL = "http://globalquotes.xignite.com/v3/xGlobalQuotes.json" <<
"/GetGlobalDelayedQuote?IdentifierType=Symbol&_token=" <<
"#{ENV["XIGNITE_TOKEN"]}&Identifier="
