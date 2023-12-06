# == Schema Information
#
# Table name: treasury_proposals
#
#  id             :bigint           not null, primary key
#  proposal_index :integer
#  created_block  :integer
#  status         :integer
#  reward         :string
#  reward_extra   :string
#  beneficiary    :jsonb
#  timeline       :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer
#  network_id     :integer
#
class TreasuryProposal < ApplicationRecord
  include RealStep

  enum status: %w[proposed rejected]

  has_one :governance_step, as: :real_step
  belongs_to :proposer, class_name: 'User', foreign_key: :user_id
  has_one :governance, through: :governance_step

  belongs_to :network

  ##################################
  # Bind to a governance
  ##################################
  after_create :bind_governance

  def previous_governance_step; end

  def real_step_key
    proposal_index
  end

  def created_time
    timeline_first = timeline.present? && timeline.first
    raise 'Timeline not found' if timeline_first.nil?

    Time.parse(timeline_first['timestamp'])
  end

  def bind_governance
    GovernanceStep.new_from_real_step(self)
  end
end
