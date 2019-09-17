class CreateVotes < ActiveRecord::Migration[5.2]
  def change
    create_table :votes do |t|
      t.string :candidate, null: false
      t.timestamps
    end
  end
end
