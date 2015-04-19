require 'bundler'
Bundler.require

enable :sessions

get '/' do
  "Welcome to Montext!"
end

get '/inbound' do
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

def parse_msg(user_msg)
    msg_arr = user_msg.to_s.split(" ")
    {
      exchange: "XNAS",
      ticker: msg_arr.first.upcase,
      element_arr: msg_arr[1..-1]
    }
end

def xignite_response(request)
  exchange = request[:exchange]
  ticker   = request[:ticker]
  elements = request[:element_arr]

  elements.map!(&:downcase).map!(&:capitalize)

  uri = XIGNITE_URL + ticker + "." + exchange
  res = HTTParty.get(uri)

  res[:ticker]   = ticker
  res[:exchange] = exchange
  res[:elements] = elements

  return res
end

def create_reply(response)
  r = response

  if successful?(r)
    display_response(r)
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
