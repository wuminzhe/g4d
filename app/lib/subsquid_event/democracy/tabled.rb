class SubsquidEvent
  module Democracy
    module Tabled
      class << self
        def handle(event)
          proposal = DemocracyPublicProposal.find_by(
            network: event.network,
            proposal_index: event.args['proposalIndex']
          )
          raise 'DemocracyPublicProposal not existed' if proposal.nil?

          timeline_step = {
            event_index: event.index,
            timestamp: event.block_timestamp,
            extrinsic_index: event.call_extrinsic_index,
            status: 'tabled'
          }
          proposal.update(
            status: 'tabled',
            updated_block: event.block_height,
            timeline: proposal.timeline.push(timeline_step)
          )
          proposal
        end
      end
    end
  end
end
