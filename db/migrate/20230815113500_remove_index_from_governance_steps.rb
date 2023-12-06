class RemoveIndexFromGovernanceSteps < ActiveRecord::Migration[7.0]
  def change
    remove_index :governance_steps, %i[real_step_type real_step_index], unique: true
    add_index :governance_steps, %i[real_step_type real_step_index]
  end
end
