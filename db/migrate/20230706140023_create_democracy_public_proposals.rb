class CreateDemocracyPublicProposals < ActiveRecord::Migration[7.0]
  def change
    create_table :democracy_public_proposals do |t|
      t.integer :network_id
      t.integer :proposal_index
      t.integer :status
      t.integer :created_block
      t.integer :updated_block
      t.string :preimage_hash
      t.string :value
      t.integer :seconded_count, default: 0
      t.integer :block_timestamp
      t.jsonb :timeline
      t.integer :preimage_id

      t.timestamps
    end
    add_index :democracy_public_proposals, %i[network_id proposal_index], unique: true, name: 'public_proposals_index'
    add_index :democracy_public_proposals, :preimage_hash
  end
end
