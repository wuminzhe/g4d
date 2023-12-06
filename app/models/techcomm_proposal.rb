# == Schema Information
#
# Table name: techcomm_proposals
#
#  id                   :bigint           not null, primary key
#  network_id           :integer
#  proposal_index       :integer
#  created_block        :integer
#  updated_block        :integer
#  aye_votes            :integer
#  nay_votes            :integer
#  status               :integer
#  proposal_hash        :string
#  threshold            :integer
#  executed_success     :boolean
#  value                :string
#  proposal_call_module :string
#  proposal_call_name   :string
#  proposal_call_params :jsonb
#  votes                :jsonb
#  timeline             :jsonb
#  preimage_id          :integer
#  preimage_hash        :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :integer
#
class TechcommProposal < ApplicationRecord
  include RealStep

  enum status: %w[proposed approved disapproved closed executed]

  has_one :governance_step, as: :real_step
  has_one :governance, through: :governance_step

  belongs_to :network
  belongs_to :proposer, class_name: 'User', foreign_key: :user_id
  belongs_to :preimage, optional: true

  def self.find_by_key(network, key)
    if key.start_with?('0x')
      TechcommProposal.find_by(network:, proposal_hash: key)
    else
      TechcommProposal.find_by(network:, proposal_index: key)
    end
  end

  def self.create_from_event(event)
    if event.event_name == 'Proposed'
      proposal_index = event.args['proposalIndex']
      status = 'proposed'
    elsif event.event_name == 'Executed'
      proposal_index = nil
      status = 'executed'
    end

    proposal_call_module = event.call_args['proposal']['__kind']
    proposal_call_name = event.call_args['proposal']['value']['__kind']
    proposal_call_params = event.call_args['proposal']['value'].delete_if { |k, _v| k == '__kind' }

    user = event.caller
    create(
      network: event.network,
      proposal_index:,
      proposal_hash: event.args['proposalHash'],
      created_block: event.block_height,
      updated_block: event.block_height,
      status:,
      user_id: user.id,
      threshold: event.call_args['threshold'],
      proposal_call_module:,
      proposal_call_name:,
      proposal_call_params:,
      votes: [],
      timeline: [{
        event_index: event.index,
        timestamp: event.block_timestamp,
        extrinsic_index: event.call_extrinsic_index,
        status:
      }]
    )
  end

  ##################################
  # Fill optional fields
  ##################################
  before_create :fill_optional_fields

  def fill_optional_fields
    # fill preimage
    return unless proposal_call_module == 'Democracy' && proposal_call_name == 'fast_track'

    self.preimage_hash = proposal_call_params['proposalHash']
    # may be null
    self.preimage = Preimage.find_by(preimage_hash:)
  end

  ##################################
  # Bind to a governance
  ##################################
  after_create :bind_governance

  def previous_governance_step
    if proposal_call_module == 'Democracy' && proposal_call_name == 'fast_track'
      # the external_proposal to fast_track
      external_proposal = DemocracyExternalProposal.last_before(
        created_block, network.id, 'preimage_hash=?',
        [preimage_hash]
      )
      external_proposal.governance_step
    elsif proposal_call_module == 'Democracy' && proposal_call_name == 'cancel_proposal'
      # the public_proposal to cancel
      public_proposal = DemocracyPublicProposal.find_by(
        proposal_index: proposal_call_params['propIndex']
      )
      public_proposal.governance_step
    else
      raise "Unimplemented techcomm proposal business #{proposal_call_module}.#{proposal_call_name}"
    end
  end

  def real_step_key
    proposal_index || proposal_hash
  end

  def created_time
    timeline_first = timeline.present? && timeline.first
    raise 'Timeline not found' if timeline_first.nil?

    Time.parse(timeline_first['timestamp'])
  end

  def bind_governance
    # external_proposal -> DemocracyReferendum
    # external_proposal -> TechcommProposal ->  DemocracyReferendum

    # 照理 TechcommProposal 之前应该没有referendum，但是pangolin 里面是referendum在先，
    # 所以这里要处理一下，看下同一个块里有没有referendum
    referendum = DemocracyReferendum.where(network:, preimage_hash:, created_block:).last
    if referendum
      force_seq = referendum.governance_step.seq - 1
      GovernanceStep.new_from_real_step(self, force_seq)
    else
      GovernanceStep.new_from_real_step(self)
    end
  end
end
