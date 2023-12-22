class AddDayToTalks < ActiveRecord::Migration[6.0]
  def change
    add_column(:talks, :day, :string)
  end
end
