class AlgoPositionsController < ApplicationController
  def index
    @positions = [
      {date: "09/23/13", price: 30.26, volume: 100, pv: 100},
      {date: "09/24/13", price: 31.27, volume: 120, pv: 120},
      {date: "09/25/13", price: 31.34, volume: 120, pv: 120}]
    render :json => @positions
  end
end
