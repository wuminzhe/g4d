class SubsquidEvent
  module Democracy
    module Seconded
      class << self
        def handle(event)
          proposal = DemocracyPublicProposal.find_by(network: event.network, proposal_index: event.args['propIndex'])
          raise 'DemocracyPublicProposal not existed' if proposal.nil?

          second = {
            event_index: event.index,
            timestamp: event.block_timestamp,
            extrinsic_index: event.call_extrinsic_index,
            seconder: event.args['seconder']
          }
          proposal.update(
            updated_block: event.block_height,
            seconds: proposal.seconds.push(second),
            seconded_count: proposal.seconded_count + 1
          )
          proposal
        end
      end
    end
  end
end
