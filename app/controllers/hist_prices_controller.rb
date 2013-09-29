class HistPricesController < ApplicationController
  def index
    @prices = [
      {date: 09/23/13, price: 30.26},
      {date: 09/24/13, price: 31.27},
      {date: 09/25/13, price: 31.34},
      {date: 09/26/13, price: 32.75},
      {date: 09/27/13, price: 33.55}]
    render :json => @prices
  end
end
