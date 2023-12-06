# == Schema Information
#
# Table name: governance_steps
#
#  id              :bigint           not null, primary key
#  governance_id   :integer
#  real_step_id    :integer
#  real_step_type  :string
#  real_step_index :string
#  real_step_block :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  seq             :integer
#
class GovernanceStep < ApplicationRecord
  belongs_to :governance
  belongs_to :real_step, polymorphic: true

  def display_name
    short_name = real_step_type.starts_with?('Democracy') ? real_step_type[9..] : real_step_type
    if real_step_type == 'DemocracyExternalProposal'
      short_name
    else
      key = real_step.real_step_key.to_s
      key = key.truncate(8) if key.length > 8

      "#{short_name} ##{key}"
    end
  end

  def self.new_from_real_step(real_step, force_seq = nil)
    # ---------------------------------- ▼
    previous_governance_step = real_step.previous_governance_step

    gov, seq =
      if previous_governance_step.nil?
        [
          Governance.new_from_real_step(real_step),
          100 # the seq of current governance step
        ]
      else
        raise 'not found governance' if previous_governance_step.governance.nil?

        [
          previous_governance_step.governance,
          previous_governance_step.seq + 100
        ]
      end

    GovernanceStep.create!(
      governance: gov,
      seq: force_seq || seq,
      real_step:,
      # ------------------------ ▼
      real_step_index: real_step.real_step_key,
      real_step_block: real_step.created_block
    )
  end
end
