require 'bundler'
Bundler.require

enable :sessions

get '/' do
  "Welcome to Montext! Get financial info through SMS. Text +1 954-621-3373 to get started."
end

get '/inbound' do
  session[:exchange] ||= "XNAS"
  session["count"] ||= 0
  user_msg_body = params["Body"]

  twiml = Twilio::TwiML::Response.new do |r|
    r.Message do |msg|
      request = parse_msg(user_msg_body)
      resp = xignite_response(request)
      msg.Body create_reply(resp)
    end
  end

  session["count"] += 1
  twiml.text
end

XIGNITE_URL = "http://globalquotes.xignite.com/v3/xGlobalQuotes.json" <<
  "/GetGlobalDelayedQuote?IdentifierType=Symbol&_token=" <<
  "#{ENV["XIGNITE_TOKEN"]}&Identifier="

def accepted_elements
  [
    "Outcome",
    "Message",
    "Delay",
    "Date",
    "Time",
    "Open",
    "Close",
    "High",
    "Low",
    "Last",
    "Volume",
    "PreviousClose",
    "PreviousCloseDate",
    "High52Weeks",
    "Low52Weeks",
    "Currency"
  ]
end

def security_data
  [
    "Name",
    "Symbol",
    "Market"
  ]
end
