class CreateTechcommProposals < ActiveRecord::Migration[7.0]
  def change
    create_table :techcomm_proposals do |t|
      t.integer :network_id
      t.integer :proposal_index
      t.integer :created_block
      t.integer :updated_block
      t.integer :aye_votes
      t.integer :nay_votes
      t.integer :status
      t.string :proposal_hash
      t.jsonb :proposer
      t.integer :member_count
      t.boolean :executed_success
      t.string :value
      t.string :call_module
      t.string :call_name
      t.jsonb :call_params
      t.jsonb :votes
      t.jsonb :timeline
      t.integer :preimage_id
      t.string :preimage_hash

      t.timestamps
    end
  end
end
