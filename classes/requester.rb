module Montext
  class Requester
    def initialize(request)
      @request = request
    end

    attr_reader :request

    def make_request
      return "New exchange" if request[:new_exchange]

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

    XIGNITE_URL = "http://globalquotes.xignite.com/v3/xGlobalQuotes.json" <<
    "/GetGlobalDelayedQuote?IdentifierType=Symbol&_token=" <<
    "#{ENV["XIGNITE_TOKEN"]}&Identifier="
  end
end
