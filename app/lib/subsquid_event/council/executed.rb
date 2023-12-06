class SubsquidEvent
  module Council
    module Executed
      class << self
        def handle(event)
          motion =
            case event.call_name
            when 'Council.close'
              council_close(event)
            when 'Council.propose'
              council_propose(event)
            else
              raise "Unimplemented call name `#{event.call_name}` for `Council.Executed`"
            end

          if motion.motion_call_module == 'Democracy' && motion.motion_call_name == 'external_propose_majority'
            motion.create_external_proposal
          end

          motion
        end

        private

        def council_close(event)
          motion = CouncilMotion.find_by(network: event.network, motion_hash: event.args['proposalHash'])
          raise "CouncilMotion #{event.args['proposalHash']} not existed" if motion.nil?

          timeline_step = {
            event_index: event.index,
            timestamp: event.block_timestamp,
            extrinsic_index: event.call_extrinsic_index,
            status: 'executed'
          }
          motion.update(
            status: 'executed',
            timeline: motion.timeline.push(timeline_step),
            updated_block: event.block_height,
            executed_success: true
          )

          motion
        end

        # pangolin specific case
        def council_propose(event)
          motion = CouncilMotion.find_by(network: event.network, motion_hash: event.args['proposalHash'])
          if motion && motion.created_block == event.block_height
            raise "CouncilMotion #{event.args['proposalHash']} existed"
          end

          CouncilMotion.create_from_event(event)
        end
      end
    end
  end
end
