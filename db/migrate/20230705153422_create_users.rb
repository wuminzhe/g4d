class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :address
      t.datetime :last_seen_at
      t.string :name

      t.timestamps
    end
    add_index :users, :address, unique: true
  end
end
