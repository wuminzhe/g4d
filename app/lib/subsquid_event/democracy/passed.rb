class SubsquidEvent
  module Democracy
    module Passed
      class << self
        def handle(event)
          referendum = DemocracyReferendum.find_by(network: event.network, referendum_index: event.args['refIndex'])
          raise 'DemocracyReferendum not found' if referendum.nil?

          timeline_step = {
            event_index: event.index,
            timestamp: event.block_timestamp,
            extrinsic_index: event.call_extrinsic_index,
            status: 'passed'
          }
          referendum.update(
            status: 'passed',
            updated_block: event.block_height,
            timeline: referendum.timeline.push(timeline_step)
          )
          referendum
        end
      end
    end
  end
end
