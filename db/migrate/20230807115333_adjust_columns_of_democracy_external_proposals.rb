class AdjustColumnsOfDemocracyExternalProposals < ActiveRecord::Migration[7.0]
  def change
    remove_column :democracy_external_proposals, :motion_hash, :string
    remove_column :democracy_external_proposals, :motion_propose_call_id, :string
    remove_column :democracy_external_proposals, :motion_proposed_at_block, :string
    rename_column :democracy_external_proposals, :motion_executed_at_block, :created_block
    rename_column :democracy_external_proposals, :motion_index, :council_motion_id
    add_column :democracy_external_proposals, :updated_block, :integer
    add_column :democracy_external_proposals, :status, :integer
    add_column :democracy_external_proposals, :timeline, :jsonb
  end
end
