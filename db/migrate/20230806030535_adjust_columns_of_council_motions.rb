class AdjustColumnsOfCouncilMotions < ActiveRecord::Migration[7.0]
  def change
    rename_column :council_motions, :member_count, :threshold
    rename_column :council_motions, :call_module, :motion_call_module
    rename_column :council_motions, :call_name, :motion_call_name
    rename_column :council_motions, :call_params, :motion_call_params
    remove_column :council_motions, :proposer
    add_column :council_motions, :user_id, :integer
    add_column :council_motions, :preimage_id, :integer
  end
end
