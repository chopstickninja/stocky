class FixDate < ActiveRecord::Migration
def change
	remove_column :strategies, :start_date
	add_column :strategies, :start_date, :string
end
end
