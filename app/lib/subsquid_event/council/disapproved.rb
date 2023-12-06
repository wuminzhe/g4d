class SubsquidEvent
  module Council
    module Disapproved
      class << self
        def handle(event)
          council_motion = CouncilMotion.find_by(network: event.network, motion_hash: event.args['proposalHash'])
          raise "CouncilMotion #{event.args['proposalHash']} not existed" if council_motion.nil?

          timeline_step = {
            event_index: event.index,
            timestamp: event.block_timestamp,
            extrinsic_index: event.call_extrinsic_index,
            status: 'disapproved'
          }
          council_motion.update(
            status: 'disapproved',
            updated_block: event.block_height,
            timeline: council_motion.timeline.push(timeline_step)
          )

          council_motion
        end
      end
    end
  end
end
