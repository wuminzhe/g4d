class SubsquidEvent
  module Council
    module Closed
      class << self
        def handle(event)
          council_motion = CouncilMotion.find_by(network: event.network, motion_index: event.call_args['index'])
          raise "CouncilMotion #{event.call_args['index']} not existed" if council_motion.nil?

          timeline_step = {
            event_index: event.index,
            timestamp: event.block_timestamp,
            extrinsic_index: event.call_extrinsic_index,
            status: 'closed'
          }
          council_motion.update(
            status: 'closed',
            updated_block: event.block_height,
            timeline: council_motion.timeline.push(timeline_step)
          )

          council_motion
        end
      end
    end
  end
end
