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
    # params: {day1, day2}

  end
end
