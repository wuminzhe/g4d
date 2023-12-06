class RemoveIndexFromDemocracyExternalProposals < ActiveRecord::Migration[7.0]
  def change
    remove_index :democracy_external_proposals, :preimage_hash, unique: true
  end
end
