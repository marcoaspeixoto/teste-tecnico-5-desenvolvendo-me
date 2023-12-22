class AddStartTimeToTalks < ActiveRecord::Migration[6.1]
  def change
    add_column :talks, :start_time, :time
  end
end
