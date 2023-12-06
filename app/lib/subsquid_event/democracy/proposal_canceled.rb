class SubsquidEvent
  module Democracy
    module ProposalCanceled
      class << self
        # crab:
        # {
        #   "id": "0000009214-000017-7bc75",
        #   "name": "Democracy.ProposalCanceled",
        #   "args": {
        #     "propIndex": 0
        #   },
        #   "call": {
        #     "name": "TechnicalCommittee.close",
        #     "args": {
        #       "index": 0,
        #       "lengthBound": 3,
        #       "proposalHash": "0xdb6a8402a69fdbe1bde646ae3f6067a91ab6bf9b754ff9788d6337089abb4a86",
        #       "proposalWeightBound": {
        #         "proofSize": "0",
        #         "refTime": "617916000"
        #       }
        #     }
        #   }
        # }
        def handle(event)
          proposal = DemocracyPublicProposal.find_by(
            network: event.network,
            proposal_index: event.args['propIndex']
          )
          raise 'DemocracyPublicProposal not exists' if proposal.nil?

          timeline_step = {
            event_index: event.index,
            timestamp: event.block_timestamp,
            extrinsic_index: event.call_extrinsic_index,
            status: 'proposal_canceled'
          }
          proposal.update(
            status: 'proposal_canceled',
            updated_block: event.block_height,
            timeline: proposal.timeline.push(timeline_step)
          )
        end
      end
    end
  end
end
