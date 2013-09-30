# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.create(username: "test", password: "password")

strategy1 = Strategy.create(query: "buy 500 YHOO when price decreases 0.5", callback: "sell 500 YHOO when price increases 0.5", user_id: user.id, start_date: "09/27/13")
strategy2 = Strategy.create(query: "buy 500 FB when price decreases 0.5", callback: "sell 500 FB when price increases 0.5", user_id: user.id, start_date: "09/27/13")
strategy3 = Strategy.create(query: "buy 500 MSFT when price decreases 0.5", callback: "sell 500 MSFT when price increases 0.5", user_id: user.id, start_date: "09/27/13")