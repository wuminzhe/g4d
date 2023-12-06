# == Schema Information
#
# Table name: democracy_external_proposals
#
#  id                :bigint           not null, primary key
#  network_id        :integer
#  council_motion_id :integer
#  created_block     :integer
#  preimage_hash     :string
#  preimage_id       :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  updated_block     :integer
#  status            :integer
#  timeline          :jsonb
#
class DemocracyExternalProposal < ApplicationRecord
  include RealStep

  enum status: %w[proposed external_tabled vetoed blacklisted]
  has_one :governance_step, as: :real_step
  has_one :governance, through: :governance_step

  belongs_to :network
  belongs_to :council_motion
  belongs_to :preimage

  delegate :proposer, to: :council_motion

  ##################################
  # Bind to a governance
  ##################################
  after_create :bind_governance

  def previous_governance_step
    raise 'External proposal should have a previous_governance_step' unless council_motion.governance_step

    council_motion.governance_step
  end

  def real_step_key
    preimage_hash
  end

  def bind_governance
    GovernanceStep.new_from_real_step(self)
  end
end
