class SubsquidEvent
  module TechnicalCommittee
    module Voted
      def self.handle(event)
        techcomm_proposal = TechcommProposal.find_by(
          network: event.network,
          proposal_index: event.call_args['index']
        )
        raise "TechcommProposal #{event.call_args['index']} not existed" if techcomm_proposal.nil?

        vote = {
          account: event.args['account'],
          voted: event.args['voted'] == true ? 'aye' : 'nay',
          voted_at: event.block_timestamp,
          extrinsic_index: event.call_extrinsic_index
        }
        techcomm_proposal.update(
          aye_votes: event.args['yes'],
          nay_votes: event.args['no'],
          votes: techcomm_proposal.votes.push(vote),
          updated_block: event.block_height
        )

        techcomm_proposal
      end
    end
  end
end
