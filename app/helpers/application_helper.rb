
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

    def initialize(entry_query, exit_query, duration_examined, max_open_trades)
      @entry = generate_trade_hash(entry_query)
      @exit = generate_trade_hash(exit_query)
      @duration_examined = duration_examined
      @max_open_trades = max_open_trades
      @portfolio = 100000
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

    # WHEN [AAPL] INCREASES BY .01 IN 1 DAY
    # WHEN [GOOG] INCREASES BY .05 IN 1 WEEK FOR 182 DAYS
    # =>
    # when ticker change by increment per duration for length

    def get_prices(ticker, duration_examined)
      yql = Yql::Client.new
      yql.format = "json"
      daily_data = [[]] #daily prices IPO - now
      res = [0] #temp holder for year's prices
      endDate = DateTime.now
      query = Yql::QueryBuilder.new 'yahoo.finance.historicaldata'
      query.select = 'date, Open, High, Low, Volume, Adj_close'
      yql.query = query

      
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


    def execute_query
      start_dates = []
      @entry[:tickers].each do |ticker|
        start_dates += find_ranges(ticker, @entry[:cond_percentage], @entry[:cond_days1], @entry[:cond_days2])
      end
      start_trade = {ticker: @entry[:act_ticker], source_of_funds: @entry[:source_of_funds], act_percentage: @entry[:act_percentage]}

      end_dates = []
      @exit[:tickers].each do |ticker|
        end_dates += find_ranges(ticker, @exit[:cond_percentage], @exit[:cond_days1], @exit[:cond_days2])
      end

      if @exit[:exit]
        end_trade = {ticker: @exit[:act_ticker], exit_all: true}
        trades = select_made_trades(start_dates, end_dates, true)
      else
        end_trade = {ticker: @exit[:act_ticker], source_of_funds: @exit[:source_of_funds], act_percentage: @exit[:act_percentage]}
        trades = make_trades(select_made_trades(start_dates, end_dates), start_trade, end_trade)
      end

    end

    def make_trades(trades, start_trade, end_trade)      
      start_trades = trades[0].dup
      end_trades = trades[1].dup
      trade_history = []
      holdings = []
      until start_trades.empty? && end_trades.empty?
        if start_trades.empty? || start_trades[0] >= end_trades[0]
          date = end_trades.shift
          price = @stock_data[end_trade[:ticker]][date]['Adj_Close']
          holdings_value = holdings.inject(0) { |trade| trade[:volume] * price }
          if end_trade[:exit_all] && !holdings.empty?
            holdings = []
            @portfolio += holdings_value
          elsif !holdings.empty?
            cash_to_spend = start_trade[:source_of_funds] == "portfolio" ? holdings_value * start_trade[:act_percentage] : @portfolio * start_trade[:act_percentage] 
            volume = (cash_to_spend / price).to_i
            @portfolio -= volume * price
            holdings << { volume: volume }
            trade_history << { volume: volume, bought_at: price}
          end
        elsif end_trades.empty? || end_trades[0] >= start_trades[0]
          date = start_trades.shift
          price = @stock_data[start_trade[:ticker]][date]['Adj_Close']
          holdings_value = holdings.inject(0) { |trade| trade[:volume] * price }
          cash_to_spend = start_trade[:source_of_funds] == "portfolio" ? holdings_value * start_trade[:act_percentage] : @portfolio * start_trade[:act_percentage] 
          volume = (cash_to_spend / price).to_i
          @portfolio -= volume * price
          holdings << { volume: volume }
          trade_history << { volume: volume, bought_at: price}
        end
        holdings
      end



          
    end

    def select_made_trades(start_dates, end_dates, exit_all_bool=false)
      open_trades = 0
      trade_dates = (start_dates + end_dates).sort.uniq
      entries = []
      exits = []
      trade_dates.each do |trade_date|
        if @max_open_trades >= open_trades && start_dates.include?(trade_date)
          open_trades += 1
          entries << trade_date
        end
        if open_trade > 0 && end_date.include?(trade_date)
          if exit_all_bool
            open_trades = 0
          else
            open_trades -=1
          end
          exits << trade_date
        end
      end
      [entries, exits]
    end

    def get_prices(ticker)
      if @stock_data[ticker].keys.count > 250 * @duration_examined
        return @stock_data[ticker]
      else
        @stock_data[ticker] = {}
        yql = Yql::Client.new
        yql.format = "json"
        daily_data = [] #daily prices IPO - now
        res = [0] #temp holder for year's prices
        endDate = DateTime.now
        query = Yql::QueryBuilder.new 'yahoo.finance.historicaldata'
        query.select = 'date, Open, High, Low, Volume, Adj_Close'
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

          res.each do |day_data|
            date = day_data.delete("date")
            @stock_data[ticker][date] = day_data
          end

          endDate = endDate - 1.year
        end
      end
      @stock_data[ticker].sort{ |day1, day2| day1.first <=> day2.first }
    end

 def find_ranges(ticker, change, duration, length = 1)
      days = [] #days that trigger entry signal
      unless @stock_data[ticker].keys.count > 250 * @duration_examined
        get_prices(ticker)
      end

      decrease = change < 0 ? true : false
      
      @stock_data[ticker].each_with_index do |day_data, idx|
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
        (days.count - 1).times do |idx|
          start = days[idx]
          count = 0
          end_d = days[idx + 1 + count]
          while self.get_successive_days(start, end_d, duration) &&
            count < length
            count += 1
            end_d = days[idx + 1 + count]
          end
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
end
