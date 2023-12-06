class CreatePreimages < ActiveRecord::Migration[7.0]
  def change
    create_table :preimages do |t|
      t.integer :network_id
      t.string :preimage_hash
      t.integer :created_block
      t.integer :updated_block
      t.integer :status
      t.string :amount
      t.string :call_module
      t.string :call_name
      t.jsonb :call_params
      t.jsonb :author

      t.timestamps
    end
    add_index :preimages, %i[network_id preimage_hash], unique: true
  end
end
