class CreateNetworks < ActiveRecord::Migration[7.0]
  def change
    create_table :networks do |t|
      t.string :chain_id, index: { unique: true }
      t.string :name

      t.timestamps
    end
  end
end
