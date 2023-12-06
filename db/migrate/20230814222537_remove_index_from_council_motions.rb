class RemoveIndexFromCouncilMotions < ActiveRecord::Migration[7.0]
  def change
    remove_index :council_motions, :motion_index, unique: true
    remove_index :council_motions, :motion_hash, unique: true
  end
end
