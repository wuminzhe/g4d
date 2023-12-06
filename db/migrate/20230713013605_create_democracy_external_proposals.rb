class CreateDemocracyExternalProposals < ActiveRecord::Migration[7.0]
  def change
    create_table :democracy_external_proposals do |t|
      t.integer :network_id
      t.integer :motion_index
      t.string :motion_hash
      t.string :motion_propose_call_id
      t.integer :motion_proposed_at_block
      t.integer :motion_executed_at_block
      t.string :preimage_hash
      t.integer :preimage_id

      t.timestamps
    end
    add_index :democracy_external_proposals, :motion_propose_call_id
    add_index :democracy_external_proposals, :motion_hash, unique: true
    add_index :democracy_external_proposals, :preimage_hash, unique: true
  end
end
