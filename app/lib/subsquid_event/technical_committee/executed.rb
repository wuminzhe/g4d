class SubsquidEvent
  module TechnicalCommittee
    module Executed
      class << self
        def handle(event)
          case event.call_name
          when 'TechnicalCommittee.close'
            technical_committee_close(event)
          when 'TechnicalCommittee.propose'
            technical_committee_propose(event)
          else
            raise "Unimplemented call name `#{event.call_name}` for `TechnicalCommittee.Executed`"
          end
        end

        private

        def technical_committee_close(event)
          techcomm_proposal = TechcommProposal.find_by(
            network: event.network,
            proposal_index: event.args['proposalHash']
          )
          raise "TechcommProposal #{event.args['proposalHash']} not existed" if techcomm_proposal.nil?

          timeline_step = {
            event_index: event.index,
            timestamp: event.block_timestamp,
            extrinsic_index: event.call_extrinsic_index,
            status: 'executed'
          }
          techcomm_proposal.update(
            status: 'executed',
            timeline: techcomm_proposal.timeline.push(timeline_step),
            updated_block: event.block_height,
            executed_success: true
          )

          techcomm_proposal
        end

        # pangolin specific case
        # {
        #   "id": "0000906588-000003-e5f40",
        #   "name": "TechnicalCommittee.Executed",
        #   "args": {
        #     "proposalHash": "0x9d437d259166cc9200b31ec281fd9b3bf3c02ea806bc2c2fbd43534901d1df12",
        #     "result": {
        #       "__kind": "Err",
        #       "value": {
        #         "__kind": "Module",
        #         "value": {
        #           "error": "0x06000000",
        #           "index": 18
        #         }
        #       }
        #     }
        #   },
        #   "call": {
        #     "name": "TechnicalCommittee.propose",
        #     "args": {
        #       "lengthBound": 43,
        #       "proposal": {
        #         "__kind": "Democracy",
        #         "value": {
        #           "__kind": "fast_track",
        #           "delay": 1,
        #           "proposalHash": "0x62dcd2fc59b9bb1cf7fc9034598e67367b7845d1e72f21a8302a55a4d005b04b",
        #           "votingPeriod": 10
        #         }
        #       },
        #       "threshold": 1
        #     }
        #   }
        # }
        def technical_committee_propose(event)
          return unless event['args']['result']['__kind'] != 'Err'

          techcomm_proposal = TechcommProposal.find_by(
            network: event.network,
            proposal_index: event.args['proposalHash']
          )
          raise "TechcommProposal #{event.args['proposalHash']} existed" if techcomm_proposal

          TechcommProposal.create_from_event(event)
        end
      end
    end
  end
end
