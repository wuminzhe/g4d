class SubsquidEvent
  module Treasury
    module Proposed
      def self.handle(event)
        treasury_proposal = TreasuryProposal.find_by(
          network: event.network,
          proposal_index: event.args['proposalIndex']
        )
        raise 'TreasuryProposal existed' unless treasury_proposal.nil?

        user = event.caller
        TreasuryProposal.create(
          network: event.network,
          proposal_index: event.args['proposalIndex'],
          created_block: event.block_height,
          status: 'proposed',
          beneficiary: event.call_args['beneficiary'],
          user_id: user.id,
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
