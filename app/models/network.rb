# == Schema Information
#
# Table name: networks
#
#  id         :bigint           not null, primary key
#  chain_id   :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  subscan    :string
#
class Network < ApplicationRecord
  has_many :governances

  has_many :preimages
  has_many :democracy_referendums
  has_many :democracy_public_proposals
  has_many :council_motions
  has_many :democracy_external_proposals
  has_many :techcomm_proposals

  def latest_democracy_public_proposal_index
    democracy_public_proposals.order(proposal_index: :desc).first&.proposal_index || -1
  end

  def latest_democracy_referendum_index
    democracy_referendums.order(referendum_index: :desc).first&.referendum_index || -1
  end

  def latest_council_motion_index
    council_motions.order(motion_index: :desc).first&.motion_index || -1
  end

  def latest_extenrnal_proposal_motion_propose_call_id
    democracy_external_proposals.order(motion_propose_call_id: :desc).first&.motion_propose_call_id
  end

  def latest_techcomm_proposal_index
    techcomm_proposals.order(proposal_index: :desc).first&.proposal_index || -1
  end
end
