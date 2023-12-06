class SubsquidEvent
  module Council
    module Voted
      class << self
        def handle(event)
          council_motion = CouncilMotion.find_by(network: event.network, motion_index: event.call_args['index'])
          raise "CouncilMotion #{event.call_args['index']} not existed" if council_motion.nil?

          vote = {
            account: event.args['account'],
            voted: event.args['voted'] == true ? 'aye' : 'nay',
            voted_at: event.block_timestamp,
            extrinsic_index: event.call_extrinsic_index
          }
          council_motion.update(
            aye_votes: event.args['yes'],
            nay_votes: event.args['no'],
            votes: council_motion.votes.push(vote),
            updated_block: event.block_height
          )

          council_motion
        end
      end
    end
  end
end
