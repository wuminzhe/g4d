class SubsquidEvent
  module TechnicalCommittee
    module Approved
      def self.handle(event)
        techcomm_proposal = TechcommProposal.find_by(
          network: event.network,
          proposal_index: event.call_args['index']
        )
        raise "TechcommProposal #{event.call_args['index']} not existed" if techcomm_proposal.nil?

        timeline_step = {
          event_index: event.index,
          timestamp: event.block_timestamp,
          extrinsic_index: event.call_extrinsic_index,
          status: 'approved'
        }
        techcomm_proposal.update(
          status: 'approved',
          updated_block: event.block_height,
          timeline: techcomm_proposal.timeline.push(timeline_step)
        )

        techcomm_proposal
      end
    end
  end
end
