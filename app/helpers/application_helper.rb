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
        query.scan(QUERY_REGEX) do |tickers, direction,
                                    cond_delta, |
        
        end

    end
    

    private

    def 

end
