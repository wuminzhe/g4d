class SubsquidEvent
  module Democracy
    module Vetoed
      class << self
        def handle(event)
          proposal = DemocracyExternalProposal.find_by(
            network: event.network,
            preimage_hash: event.args['proposalHash']
          )
          raise 'DemocracyExternalProposal not existed' if proposal.nil?

          timeline_step = {
            event_index: event.index,
            timestamp: event.block_timestamp,
            extrinsic_index: event.call_extrinsic_index,
            status: 'vetoed',
            until: event.args['until'],
            who: event.args['who']
          }
          proposal.update(
            status: 'vetoed',
            updated_block: event.block_height,
            timeline: proposal.timeline.push(timeline_step)
          )
        end
      end
    end
  end
end
