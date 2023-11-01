class CreateTalks < ActiveRecord::Migration[6.1]
  def change
    create_table :talks do |t|
      t.string :name
      t.integer :duration

      t.timestamps
    end
  end
end
