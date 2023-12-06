class SubsquidEvent
  module Democracy
    module Blacklisted
      class << self
        def handle(event)
          proposal_hash = event.args['proposalHash']

          # find public proposal first
          proposal = DemocracyPublicProposal.find_by(preimage_hash: proposal_hash)

          # find external proposal if not found
          proposal = DemocracyExternalProposal.find_by(preimage_hash: proposal_hash) if proposal.nil?

          timeline_step = {
            event_index: event.index,
            timestamp: event.block_timestamp,
            extrinsic_index: event.call_extrinsic_index,
            status: 'blacklisted'
          }
          proposal.update(
            status: 'blacklisted',
            updated_block: block_height,
            timeline: proposal.timeline.push(timeline_step)
          )
        end
      end
    end
  end
end
