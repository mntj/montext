module Montext
  class MessageParser
    def initialize(user_msg)
      @user_msg = user_msg
    end

    attr_reader :user_msg

    def parse_msg
      msg_arr = user_msg.to_s.split(" ")

      if msg_arr.first.downcase == "set"
        session[:exchange] = msg_arr.last.upcase
        return {:new_exchange => exchange}
      end

      {
        exchange: session[:exchange],
        ticker: msg_arr.first.upcase,
        element_arr: msg_arr[1..-1]
      }
    end
  end
end
