module Montext
  class Responder
    def initialize(response)
      @res = response
    end

    attr_reader :res

    def create_response
      if res == "New exchange"
        return "Exchange set to #{session[:exchange]}"
      elsif successful?(res)
        display_response(res)
      elsif session["count"] == 0
        new_message << help_message
      elsif r["Message"]
        r["Message"]
      else
        error_message << help_message
      end
    end

    private

    def successful?(res)
      !response["Outcome"].include? "Error"
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
  end
end
