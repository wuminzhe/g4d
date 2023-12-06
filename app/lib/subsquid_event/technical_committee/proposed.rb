class SubsquidEvent
  module TechnicalCommittee
    module Proposed
      def self.handle(event)
        techcomm_proposal = TechcommProposal.find_by(
          network: event.network,
          proposal_index: event.args['proposalIndex']
        )
        raise 'TechcommProposal existed' unless techcomm_proposal.nil?

        TechcommProposal.create_from_event(event)
      end
    end
  end
end
