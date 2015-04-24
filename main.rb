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

def new_message
  "Welcome to Montext! Financial info through SMS\n"
end

def help_message
  "Enter a company symbol to get info about it. For example, 'FB' \n" <<
  "Or enter a symbol and certain attributes: 'FB Open Close' \n" <<
  "You can also set the exchange, e.g. 'Set exchange XNSE'"
end

def error_message
  "Sorry! Didn't recognize that. "
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

def display_response(res)
  if res[:elements].empty? || res[:elements].include?("All")
    display_all_data(res)
  else
    display_restricted_data(res)
  end
end

def display_all_data(res)
  resp_str = ""

  security_data.each do |el|
    if res["Security"][el]
      resp_str << el << ": " << res["Security"][el] << "\n"
    end
  end

  accepted_elements.each do |el|
    if res[el]
      resp_str << el << ": " << res[el].to_s << "\n"
    end
  end

  return resp_str
end

def display_restricted_data(res)
  resp_str = ""

  security_data.each do |el|
    if res["Security"][el]
      resp_str << el << ": " << res["Security"][el] << "\n"
    end
  end

  res[:elements].each do |el|
    if res[el]
      resp_str << el << ": " << res[el].to_s << "\n"
    end
  end

  return resp_str
end
