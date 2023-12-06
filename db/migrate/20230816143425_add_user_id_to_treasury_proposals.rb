class AddUserIdToTreasuryProposals < ActiveRecord::Migration[7.0]
  def change
    add_column :treasury_proposals, :user_id, :integer
    add_column :treasury_proposals, :network_id, :integer
    remove_column :treasury_proposals, :proposer, :jsonb
    remove_column :treasury_proposals, :council_motion_id, :integer
  end
end
