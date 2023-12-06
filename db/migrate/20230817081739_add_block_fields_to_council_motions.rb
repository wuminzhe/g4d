class AddBlockFieldsToCouncilMotions < ActiveRecord::Migration[7.0]
  def change
    add_column :council_motions, :created_block_spec_version, :integer
    add_column :council_motions, :created_block_hash, :integer
  end
end
