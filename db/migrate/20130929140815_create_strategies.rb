class CreateStrategies < ActiveRecord::Migration
  def change
    create_table :strategies do |t|
      t.string :query
      t.string :callback
      t.integer :user_id
      t.date :start_date
      t.timestamps
    end
  end
end
