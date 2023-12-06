# == Schema Information
#
# Table name: democracy_referendums
#
#  id                     :bigint           not null, primary key
#  network_id             :integer
#  referendum_index       :integer
#  author                 :jsonb
#  created_block          :integer
#  updated_block          :integer
#  preimage_id            :integer
#  preimage_hash          :string
#  vote_threshold         :integer
#  status                 :integer
#  delay                  :integer
#  end                    :integer
#  aye_amount             :string           default("0")
#  nay_amount             :string           default("0")
#  turnout                :string
#  executed_success       :boolean
#  aye_without_conviction :string           default("0")
#  nay_without_conviction :string           default("0")
#  timeline               :jsonb
#  call_module            :string
#  call_name              :string
#  block_timestamp        :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :integer
#  votes                  :jsonb
#
class DemocracyReferendum < ApplicationRecord
  include RealStep

  enum status: %w[started voted not_passed cancelled passed blacklisted]

  # SuperMajorityApprove: Public referenda
  # SimpleMajority: Referenda from council majority motion
  # SuperMajorityAgainst: Referenda from council unanimous motion
  enum vote_threshold: %w[SuperMajorityApprove SimpleMajority SuperMajorityAgainst]

  has_one :governance_step, as: :real_step
  has_one :governance, through: :governance_step

  belongs_to :network
  belongs_to :proposer, class_name: 'User', foreign_key: :user_id
  belongs_to :preimage, optional: true

  ##################################
  # Bind to a governance
  ##################################
  after_create :bind_governance

  # * public proposal
  # * external proposal
  def previous_governance_step
    if vote_threshold == 'SuperMajorityApprove'
      # 1. check public proposal by referendum_index or preimage_hash
      public_proposal =
        DemocracyPublicProposal.last_before(
          created_block, network.id, 'preimage_hash=?',
          [preimage_hash]
        )

      public_proposal.governance_step
    else
      # 2. check external proposal by preimage_hash
      external_proposal =
        DemocracyExternalProposal.last_before(
          created_block, network.id, 'preimage_hash=?',
          [preimage_hash]
        )

      external_proposal.governance_step
    end
  end

  def real_step_key
    referendum_index || preimage_hash || id
  end

  def bind_governance
    GovernanceStep.new_from_real_step(self)
  end
end
