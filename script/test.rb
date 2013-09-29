p "hello!!!"
query = "when YHOO increases by 3% in 1 day use 3% of portfolio to buy AAPL."
callback = "when YHOO decreases by 5% in 1 day or YHOO increases by 5% in 1 days exit"
duration_examined = 1
max_open_trades = 5

p obj = ApplicationHelper::Parser.new(query, callback, duration_examined,max_open_trades)
a = obj.execute_query
p a
# b = a[0] + a[1]

# p b
# p a[0] + a[2]