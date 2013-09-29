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
    DO_REGEX = /use #{PERCENTAGE} of (portfolio|free cash) to (#{ACTION}) (#{TICKER})/i
    QUERY_REGEX = /#{COND_REGEX}+(?:#{DO_REGEX}|EXIT)/i

    def initialize(query)
      query.scan(QUERY_REGEX) do |tickers, cond_direction,
                                  cond_percentage, cond_num1,
                                  cond_unit1, cond_num2,
                                  cond_unit2, act_percentage,
                                  source_of_funds, act_direction, act_ticker|
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

        act_direction = act_direction == "buy" ? 1 : -1
        act_percentage = act_percentage * 0.01
      end
    end
    
    # WHEN [AAPL] INCREASES BY .01 IN 1 DAY
    # WHEN [GOOG] INCREASES BY .05 IN 1 WEEK FOR 182 DAYS
    # =>
    # when ticker change by increment per duration for length

    def get_prices(ticker, duration_examined)
      yql = Yql::Client.new
      yql.format = "json"
      daily_data = [] #daily prices IPO - now
      res = [0] #temp holder for year's prices
      endDate = DateTime.now
      query = Yql::QueryBuilder.new 'yahoo.finance.historicaldata'
      query.select = 'date, Open, High, Low, Volume, Adj_close'
      yql.query = query
      
      duration_examined.times do
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
      daily_data
    end

    def find_ranges(ticker, change, duration, length = 0, duration_examined = 10)
      days = [] #days that trigger entry signal
      daily_data = get_prices(ticker, duration_examined)
      
      daily_data.each_with_index do |day_data, idx|
        start = day_data
        end_d = daily_data[idx + duration - 1]
        if end_d && (start["High"].to_f - end_d["Low"].to_f) / start["High"].to_f <= change ||
          end_d && (start["Low"].to_f - end_d["High"].to_f) / start["Low"].to_f >= change
          days << DateTime.new(*end_d["date"].split("-").map(&:to_i))
        end
      end

      days
    end
    puts find_ranges("GOOG", 0.01, 10, 180)
  end

end