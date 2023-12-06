class SubsquidEvent
  module Council
    module Proposed
      class << self
        def handle(event)
          council_motion = CouncilMotion.find_by(network: event.network, motion_index: event.args['proposalIndex'])
          raise 'CouncilMotion existed' unless council_motion.nil?

          CouncilMotion.create_from_event(event)
        end
      end
    end
  end
end
