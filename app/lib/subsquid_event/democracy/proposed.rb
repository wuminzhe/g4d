class SubsquidEvent
  module Democracy
    module Proposed
      class << self
        def handle(event)
          proposal = DemocracyPublicProposal.find_by(
            network: event.network,
            proposal_index: event.args['proposalIndex']
          )
          raise 'DemocracyPublicProposal existed' unless proposal.nil?

          user = event.caller

          preimage = ::Preimage.find_by(
            network: event.network,
            preimage_hash: event.call_args['proposal']['hash']
          )

          DemocracyPublicProposal.create(
            network: event.network,
            proposal_index: event.args['proposalIndex'],
            preimage_hash: preimage&.preimage_hash,
            preimage:,
            created_block: event.block_height,
            updated_block: event.block_height,
            status: 'proposed',
            user_id: user.id,
            value: event.args['deposit'],
            block_timestamp: event.block_timestamp,
            votes: [],
            seconds: [],
            timeline: [{
              event_index: event.index,
              timestamp: event.block_timestamp,
              extrinsic_index: event.call_extrinsic_index,
              status: 'proposed'
            }]
          )
        end
      end
    end
  end
end
