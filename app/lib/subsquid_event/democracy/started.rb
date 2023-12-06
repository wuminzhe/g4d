class SubsquidEvent
  module Democracy
    module Started
      class << self
        def handle(event)
          referendum = DemocracyReferendum.find_by(network: event.network, referendum_index: event.args['refIndex'])
          raise 'DemocracyReferendum existed' if referendum

          user = find_user(event)
          preimage = find_preimage(event)

          DemocracyReferendum.create(
            network: event.network,
            referendum_index: event.args['refIndex'],
            preimage_hash: preimage&.preimage_hash,
            preimage:,
            created_block: event.block_height,
            updated_block: event.block_height,
            status: 'started',
            user_id: user.id,
            vote_threshold: event.args['threshold']['__kind'],
            votes: [],
            timeline: [{
              event_index: event.index,
              timestamp: event.block_timestamp,
              extrinsic_index: event.call_extrinsic_index,
              status: 'started'
            }]
          )
        end

        private

        def find_user(event)
          return event.caller if event.caller

          threshold = event.args['threshold']['__kind']
          proposer =
            if threshold == 'SuperMajorityApprove' # public proposal
              # There is no `call` for a referendum from a public proposal,
              # so we need to find the proposer from the `DemocracyPublicProposal`.
              democracy_public_proposal(event).proposer
            else # external proposal
              democracy_external_proposal(event).proposer
            end
          return proposer if proposer

          raise('Referendum proposer not found')
        end

        def find_preimage(event)
          threshold = event.args['threshold']['__kind']
          if threshold == 'SuperMajorityApprove' # public proposal
            democracy_public_proposal(event).preimage
          else # external proposal
            democracy_external_proposal(event).preimage

            # case event.call_name
            # when 'TechnicalCommittee.propose'
            #   # pangolin specific case
            #   #
            #   #   "call": {
            #   #     "name": "TechnicalCommittee.propose",
            #   #     "args": {
            #   #       "lengthBound": 43,
            #   #       "proposal": {
            #   #         "__kind": "Democracy",
            #   #         "value": {
            #   #           "__kind": "fast_track",
            #   #           "delay": 1,
            #   #           "proposalHash": "0x3913e355b807367ce2bc3b798061ee2842ba8a28cdd16ac0bee85fc540018f1c",
            #   #           "votingPeriod": 1
            #   #         }
            #   #       },
            #   #       "threshold": 1
            #   #     }
            #   #   }
            #   #
            #   # if the started event is emitted by `TechnicalCommittee.propose`,
            #   ::Preimage.find_by(preimage_hash: event.call_args['proposal']['value']['proposalHash'])
            # when 'TechnicalCommittee.close'
            #   # if the started event is emitted by `TechnicalCommittee.close`,
            #   techcomm_proposal = TechcommProposal.find_by(proposal_hash: event.call_args['proposalHash'])
            #   techcomm_proposal.preimage
            # end
          end
        end

        # find the public proposal by the `Democracy.Tabled` event on the same block.
        def democracy_public_proposal(event)
          tabled_event = event.block_events.find { |e| e['name'] == 'Democracy.Tabled' }
          DemocracyPublicProposal.find_by(
            network: event.network,
            proposal_index: tabled_event['args']['proposalIndex']
          )
        end

        def democracy_external_proposal(event)
          DemocracyExternalProposal.where(network: event.network).order(created_block: :desc).limit(1).first
        end
      end
    end
  end
end
