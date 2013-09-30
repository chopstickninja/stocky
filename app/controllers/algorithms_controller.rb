class AlgorithmsController < ApplicationController
  respond_to :json, :only => [:create, :index, :show]

  def create
    # params: {query => "...", callback => "..."}
    p params[:strategy]
    p params[:callback]
    parser = Parser.new(params[:query], params[:callback], params[:duration_examined].to_i,params[:max_open_trades].to_i)
    trades = parser.execute_query
    @algorithms = []
    trades.each do |idx, trade|
      @algorithms << trade
    end

    p @algorithms

    render "algorithms.rabl"#:handlers => [:rabl]
  end

  def show
    parser = Parser.allocate
    parser.get_prices(parmas[:ticker])
    trades = parser.stock_data(params[:ticker])
    trades.select! do |trade| 
      trade['date'] > params[:start_date] && trade['date'] < params[:end_date]
    end
    @algorithms = []
    trades.each do |idx, trade|
      @algorithms << trade
    end

    render :handlers => [:rabl]
    # params: {day1, day2}

  end
end
