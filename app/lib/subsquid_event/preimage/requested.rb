class SubsquidEvent
  module Preimage
    module Requested
      def self.handle(event)
        preimage = ::Preimage.find_by(
          network: event.network,
          preimage_hash: event.args['hash']
        )
        raise "Preimage not exists #{event.args['hash']}" unless preimage

        preimage.update(
          updated_block: event.block_height,
          status: event.event_name.downcase
        )
      end
    end
  end
end
