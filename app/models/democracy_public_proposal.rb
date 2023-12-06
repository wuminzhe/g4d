# == Schema Information
#
# Table name: democracy_public_proposals
#
#  id              :bigint           not null, primary key
#  network_id      :integer
#  proposal_index  :integer
#  status          :integer
#  created_block   :integer
#  updated_block   :integer
#  preimage_hash   :string
#  value           :string
#  seconded_count  :integer          default(0)
#  timeline        :jsonb
#  preimage_id     :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :integer
#  seconds         :jsonb
#  votes           :jsonb
#  block_timestamp :string
#
class DemocracyPublicProposal < ApplicationRecord
  include RealStep

  enum status: %w[proposed proposal_canceled tabled blacklisted]

  has_one :governance_step, as: :real_step
  has_one :governance, through: :governance_step

  belongs_to :network
  belongs_to :proposer, class_name: 'User', foreign_key: :user_id
  belongs_to :preimage, optional: true

  def author
    proposer
  end

  ##################################
  # Bind to a governance
  ##################################
  after_create :bind_governance

  def previous_governance_step; end

  def real_step_key
    proposal_index || id
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
