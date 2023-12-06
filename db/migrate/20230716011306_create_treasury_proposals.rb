class CreateTreasuryProposals < ActiveRecord::Migration[7.0]
  def change
    create_table :treasury_proposals do |t|
      t.integer :proposal_index
      t.integer :created_block
      t.integer :status
      t.string :reward
      t.string :reward_extra
      t.jsonb :beneficiary
      t.jsonb :proposer
      t.integer :council_motion_id
      t.jsonb :timeline

      t.timestamps
    end
  end
end
