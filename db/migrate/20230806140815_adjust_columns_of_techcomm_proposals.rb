class AdjustColumnsOfTechcommProposals < ActiveRecord::Migration[7.0]
  def change
    rename_column :techcomm_proposals, :member_count, :threshold
    rename_column :techcomm_proposals, :call_module, :proposal_call_module
    rename_column :techcomm_proposals, :call_name, :proposal_call_name
    rename_column :techcomm_proposals, :call_params, :proposal_call_params
    remove_column :techcomm_proposals, :proposer, :jsonb
    add_column :techcomm_proposals, :user_id, :integer
  end
end
