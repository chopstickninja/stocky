require 'yql'
require 'json'

module ApplicationHelper
  class Parser
    TICKER = /[A-Z]{1,4}/i
    CHANGE = /increases|decreases/i
    PERCENTAGE = /([0-9]+)%/i
    NUM_WITH_UNIT =/([0-9]+) (months?|days?|weeks?|years?)/i
    ACTION =/buy|sell/i
    IN_PER= /(?:IN|PER) #{NUM_WITH_UNIT}(?: FOR #{NUM_WITH_UNIT})?/i
    COND_REGEX = /(?:when|or) (#{TICKER}(?: or #{TICKER})*) (#{CHANGE}) by #{PERCENTAGE} #{IN_PER} /i
    DO_REGEX = /(?:use #{PERCENTAGE} of (portfolio|free cash) to (#{ACTION}) (#{TICKER})|(exit))/i
    QUERY_REGEX = /#{COND_REGEX}+#{DO_REGEX}/i

    def initialize(entry_query, exit_query)
      @entry = generate_trade_hash(entry_query)
      @exit = generate_trade_hash(exit_query)
    end


    def generate_trade_hash(query)
      query.scan(QUERY_REGEX) do |tickers, cond_direction,
                                  cond_percentage, cond_num1,
                                  cond_unit1, cond_num2,
                                  cond_unit2, act_percentage,
                                  source_of_funds, act_direction, act_ticker, exit|
        tickers = tickers.split(/ or /)
        cond_direction = cond_direction == "increases" ? 1 : -1
        cond_percentage = cond_percentage * 0.01 * cond_direction
      
        cond_unit1 = cond_unit1[0..-2] if cond_unit1[-1] == "s"
        cond_unit2 = cond_unit2[0..-2] if cond_unit2[-1] == "s"
        
        multiplier_unit1 = case cond_unit1
        when "day"
          1
        when "month"
          30
        when "year"
          365
        end

        multiplier_unit2 = case cond_unit2
        when "day"
          1
        when "month"
          30
        when "year"
          365
        end
        unless exit
          act_direction = act_direction == "buy" ? 1 : -1
          act_percentage = act_percentage * 0.01
        end


        output = {}
        output[:tickers] = tickers
        output[:cond_percentage] = cond_percentage
        output[:cond_days1] = multiplier_unit1 * cond_num1
        output[:cond_days2] = multiplier_unit2 * cond_num2
        if exit
          output[:exit] = true
        end

        output[:act_percentage] = act_percentage
        output[:source_of_funds] = source_of_funds
        output[:act_ticker] = act_ticker
        return output
      end
    end


    def execute_query#(start_dates, start_trade, end_dates, end_trade, portfolio = 10000)
      start_dates = []
      @entry[:tickers].each do |ticker|
        start_dates += find_ranges(ticker, @entry[:cond_percentage], @entry[:cond_days1], @entry[:cond_days2])
      end
      start_trade
      #returns an array of trades in the form [date, Ticker, volume, price]
    end


    # WHEN [AAPL] INCREASES BY .01 IN 1 DAY
    # WHEN [GOOG] INCREASES BY .05 IN 1 WEEK FOR 182 DAYS
    # =>
    # when ticker change by increment per duration for length

  def get_prices(ticker)
    if @stock_data[ticker]
      return @stock_data[ticker]
    else
      yql = Yql::Client.new
      yql.format = "json"
      daily_data = [] #daily prices IPO - now
      res = [0] #temp holder for year's prices
      endDate = DateTime.now
      query = Yql::QueryBuilder.new 'yahoo.finance.historicaldata'
      query.select = 'date, Open, High, Low, Volume, Adj_close'
      yql.query = query
      
      @duration_examined.times do
        break if res.length == 0
        startDate = endDate - 1.year
        query.conditions = { 
          :symbol => ticker, 
          :startDate => "#{startDate.year}-#{startDate.month}-#{startDate.day}", 
          :endDate => "#{endDate.year}-#{endDate.month}-#{endDate.day}" 
        }
        res = JSON.parse(yql.get.show)["query"]["results"]["quote"]
        daily_data += res
        endDate = endDate - 1.year
      end
      @stock_data[ticker] = daily_data.reverse
    end
  end

  def find_ranges(ticker, change, duration, length = 1)
    days = [] #days that trigger entry signal
    daily_data = get_prices(ticker)
    decrease = change < 0 ? true : false
    
    daily_data.each_with_index do |day_data, idx|
      start = day_data
      end_d = daily_data[idx + duration - 1]
      break unless end_d
      max_incr = (end_d["High"].to_f - start["Low"].to_f) / end_d["High"].to_f
      max_decr = (end_d["Low"].to_f - start["High"].to_f) / end_d["Low"].to_f

      if decrease && max_decr <= change || !decrease && max_incr >= change
        days << end_d["date"]
      end
    end

    if length > 1
      successive_days = []
      (days.length - 1).times do |idx|
        start = days[idx]
        count = 0
        end_d = days[idx + 1 + count]
        while self.get_successive_days(start, end_d, duration) &&
          count < length
          count += 1
          end_d = days[idx + 1 + count]
        successive_days << days[idx] if count == length - 1
      end
      return successive_days
    end
    days
  end

  def get_successive_days(start_d, end_d, duration)
    # look through each day in days. if hit a string
    # of length successive days spaced by duration,
    # extract that part and return
    start_date = DateTime.new(*start_d.split("-").map(&:to_i))
    end_date = DateTime.new(*end_d.split("-").map(&:to_i))
    return true if end_date - start_date == duration
    false
  end

end