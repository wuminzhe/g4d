# == Schema Information
#
# Table name: governances
#
#  id            :bigint           not null, primary key
#  title         :string
#  body          :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  init_time     :datetime
#  init_block    :integer
#  init_user_id  :integer
#  network_id    :integer
#  preimage_id   :integer
#  uuid          :string
#  discussion_id :integer
#
class Governance < ApplicationRecord
  belongs_to :network
  belongs_to :init_user, class_name: 'User'
  belongs_to :preimage, optional: true
  belongs_to :discussion, optional: true

  delegate :title, :body, :root_comments, to: :discussion

  # before_create :init_uuid
  #
  # def init_uuid
  #   hex = SecureRandom.hex(4)
  #   Governance.find_by(uuid: hex).nil? ? self.uuid = hex : init_uuid
  # end

  def self.new_from_real_step(real_step)
    # create a governance
    goverance = create(
      network: real_step.network,
      preimage: real_step.has_attribute?(:preimage_id) ? real_step.preimage : nil,
      init_time: real_step.created_time,
      init_block: real_step.created_block,
      init_user_id: real_step.proposer.id
    )

    # bind to a Discussion
    discussion = Discussion.create_or_find_by(
      network: real_step.network,
      first_real_step_type: real_step.class.name,
      first_real_step_key: real_step.real_step_key
    )
    goverance.update(discussion:)

    goverance
  end

  has_many :governance_steps, -> { order(seq: :asc, created_at: :asc) }, dependent: :delete_all

  # 1
  has_many :democracy_public_proposals,
           through: :governance_steps,
           source: :real_step,
           source_type: 'DemocracyPublicProposal'

  # 2
  has_many :council_motions,
           through: :governance_steps,
           source: :real_step,
           source_type: 'CouncilMotion'

  has_many :democracy_external_proposals,
           through: :governance_steps,
           source: :real_step,
           source_type: 'DemocracyExternalProposal'

  has_many :techcomm_proposals,
           through: :governance_steps,
           source: :real_step,
           source_type: 'TechcommProposal'

  has_many :democracy_referendums,
           through: :governance_steps,
           source: :real_step,
           source_type: 'DemocracyReferendum'

  # treasury
  has_many :treasury_proposals,
           through: :governance_steps,
           source: :real_step,
           source_type: 'TreasuryProposal'

  def treasury_proposal
    treasury_proposals.first
  end

  # def treasury_proposal=(proposal)
  #   if treasury_proposal.nil?
  #     GovernanceStep.create!(governance: self, real_step: proposal)
  #   elsif treasury_proposal.proposal_index != proposal.proposal_index
  #     raise "already exists a different proposal #{treasury_proposal.proposal_index}, check why"
  #   end
  # end
  #
  def democracy_referendum
    democracy_referendums.first
  end

  # def democracy_referendum=(referendum)
  #   if democracy_referendum.nil?
  #     GovernanceStep.create!(governance: self, real_step: referendum)
  #   elsif democracy_referendum.referendum_index != referendum.referendum_index
  #     raise "already exists a different referendum #{democracy_referendum.referendum_index}, check why"
  #   end
  # end
end
