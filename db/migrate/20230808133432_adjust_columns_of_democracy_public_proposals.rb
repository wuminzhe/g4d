class AdjustColumnsOfDemocracyPublicProposals < ActiveRecord::Migration[7.0]
  def change
    add_column :democracy_public_proposals, :user_id, :integer
    add_column :democracy_public_proposals, :seconds, :jsonb
    add_column :democracy_public_proposals, :votes, :jsonb
    remove_column :democracy_public_proposals, :block_timestamp, :integer
    add_column :democracy_public_proposals, :block_timestamp, :string
  end
end
