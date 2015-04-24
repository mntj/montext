module Montext
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
end
