# == Schema Information
#
# Table name: council_motions
#
#  id                         :bigint           not null, primary key
#  motion_index               :integer
#  motion_hash                :string
#  created_block              :integer
#  updated_block              :integer
#  aye_votes                  :integer
#  nay_votes                  :integer
#  status                     :integer
#  threshold                  :integer
#  executed_success           :boolean
#  value                      :string
#  motion_call_module         :string
#  motion_call_name           :string
#  motion_call_params         :jsonb
#  votes                      :jsonb
#  timeline                   :jsonb
#  network_id                 :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  user_id                    :integer
#  preimage_id                :integer
#  created_block_spec_version :integer
#  created_block_hash         :integer
#
class CouncilMotion < ApplicationRecord
  enum status: %w[proposed approved disapproved closed executed]

  has_one :governance_step, as: :real_step
  has_one :governance, through: :governance_step

  belongs_to :network
  belongs_to :proposer, class_name: 'User', foreign_key: :user_id
  belongs_to :preimage, optional: true # not every motion has preimage

  def self.find_by_key(network, key)
    if key.start_with?('0x')
      CouncilMotion.includes(
        [{ governance: { governance_steps: :real_step } }, { governance_step: :real_step }]
      ).find_by(network:, motion_hash: key)
    else
      CouncilMotion.includes(
        [
          { governance: :governance_steps }, :governance_step
        ]
      ).find_by(network:, motion_index: key)
    end
  end

  def self.create_from_event(event)
    if event.event_name == 'Proposed'
      motion_index = event.args['proposalIndex']
      status = 'proposed'
    elsif event.event_name == 'Executed'
      motion_index = nil
      status = 'executed'
    end

    motion_call_module = event.call_args['proposal']['__kind']
    motion_call_name = event.call_args['proposal']['value']['__kind']
    motion_call_params = event.call_args['proposal']['value']

    # check motion call
    unless supported_motion_call?(motion_call_module, motion_call_name)
      raise "Not supported motion_call #{motion_call_module}.#{motion_call_name}"
    end

    motion_hash = event.args['proposalHash']
    block_height = event.block_height
    threshold = event.call_args['threshold']
    timeline_step = {
      event_index: event.index,
      timestamp: event.block_timestamp,
      extrinsic_index: event.call_extrinsic_index,
      status:
    }

    user = event.caller
    create(
      network: event.network,
      motion_index:,
      motion_hash:,
      created_block: block_height,
      created_block_spec_version: event.block_spec_version,
      created_block_hash: event.block_hash,
      updated_block: block_height,
      status:,
      user_id: user.id,
      threshold:,
      motion_call_module:,
      motion_call_name:,
      motion_call_params:,
      votes: [],
      timeline: [timeline_step]
    )
  end

  ##################################
  # Fill optional fields
  ##################################
  before_create :fill_optional_fields

  def fill_optional_fields
    self.preimage = get_preimage
  end

  ##################################
  # Create external proposal
  ##################################
  def create_external_proposal
    step = timeline.last
    return unless step['status'] == 'executed'

    DemocracyExternalProposal.create(
      network:,
      council_motion: self,
      created_block: updated_block,
      updated_block:,
      preimage:,
      preimage_hash: preimage.preimage_hash,
      status: 'proposed',
      timeline: [{
        event_index: step['event_index'],
        timestamp: step['timestamp'],
        extrinsic_index: step['extrinsic_index'],
        status: 'proposed'
      }]
    )
  end

  ##################################
  # Bind to a governance
  ##################################
  after_create :bind_governance

  def previous_governance_step
    if motion_call_module == 'Treasury' && motion_call_name == 'approve_proposal'
      treasury_proposal = TreasuryProposal.find_by(network:, proposal_index: motion_call_params['proposalId'])
      treasury_proposal.governance_step
    elsif motion_call_module == 'Democracy' && motion_call_name == 'external_propose_majority'
      nil
    elsif motion_call_module == 'TechnicalMembership' && %w[add_member reset_members].include?(motion_call_name)
      nil
    else
      raise "Unimplemented council business #{motion_call_module}.#{motion_call_name}"
    end
  end

  def real_step_key
    motion_index || motion_hash
  end

  def created_time
    timeline_first = timeline.present? && timeline.first
    raise 'Timeline not found' if timeline_first.nil?

    Time.parse(timeline_first['timestamp'])
  end

  def bind_governance
    GovernanceStep.new_from_real_step(self)
  end

  ##################################
  # Helper
  ##################################
  def self.supported_motion_call?(motion_call_module, motion_call_name)
    if motion_call_module == 'Democracy'
      return true if ['external_propose_majority'].include?(motion_call_name)
    elsif motion_call_module == 'TechnicalMembership'
      return true if %w[add_member reset_members].include?(motion_call_name)
    elsif motion_call_module == 'Treasury'
      return true if ['approve_proposal'].include?(motion_call_name)
    end

    false
  end

  def get_preimage
    return unless motion_call_module == 'Democracy' && motion_call_name == 'external_propose_majority'

    kind = motion_call_params['proposal']['__kind']
    if kind == 'Lookup'

      preimage_hash = motion_call_params['proposal']['hash']
      Preimage.find_by!(preimage_hash:)

    elsif kind == 'Inline'

      puts '       create preimage inline'
      preimage_bytes = motion_call_params['proposal']['value']
      Preimage.create_from_raw_data(
        preimage_bytes,
        network,
        {
          block_spec_version: created_block_spec_version,
          block_hash: created_block_hash,
          block_height: created_block
        },
        proposer
      )

    else
      raise "Not supported external_propose_majority's kind #{kind}"
    end
  end
end
