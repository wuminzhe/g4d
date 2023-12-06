class AddSeqToGovernanceSteps < ActiveRecord::Migration[7.0]
  def change
    add_column :governance_steps, :seq, :integer
  end
end
