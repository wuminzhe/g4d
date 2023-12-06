class CreateGovernanceSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :governance_steps do |t|
      t.integer :governance_id
      t.integer :real_step_id
      t.string :real_step_type

      # BUSINESS INDEX: real_step_type + real_step_index
      # format: CouncilMotion-9
      # external_proposal has not index, use its motion's index instead
      t.string :real_step_index
      # # council_motion: motion_hash
      # # external_proposal: preimage_hash
      # # public_proposal: preimage_hash
      # # referendum: preimage_hash
      # # tc_proposal: proposal_hash
      # t.string :real_step_hash

      t.integer :real_step_block

      t.timestamps
    end

    add_index :governance_steps, %i[real_step_type real_step_index], unique: true
  end
end
