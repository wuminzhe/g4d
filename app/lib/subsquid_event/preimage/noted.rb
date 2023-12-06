class SubsquidEvent
  module Preimage
    module Noted
      class << self
        def handle(event)
          preimage = ::Preimage.find_by(
            network: event.network,
            preimage_hash: event.args['hash']
          )
          raise "Preimage already exists #{event.args['hash']}" if preimage

          case event.call_name
          when 'Preimage.note_preimage'
            preimage_note_preimage(event)
          when 'Scheduler.schedule'
            scheduler_schedule(event)
          else
            raise "Not supported call #{event.call_name} for preimage noted event"
          end
        end

        private

        def preimage_note_preimage(event)
          ::Preimage.create_from_raw_data(
            event.call_args['bytes'],
            event.network,
            {
              block_spec_version: event.block_spec_version,
              block_hash: event.block_hash,
              block_height: event.block_height
            },
            event.caller,
            event.event_name.downcase
          )
        end

        # pangolin2 event: 906637-3
        # subsquid event id: "0000906637-000003-94163"
        def scheduler_schedule(event)
          preimage_hash = event.args['hash']

          call = event.call_args['call']
          call_module = call['__kind']
          call_name = call['value']['__kind']
          call_params = call['value']

          ::Preimage.create(
            network: event.network,
            preimage_hash:,
            created_block: event[:block_height],
            updated_block: event[:block_height],
            status: 'noted',
            user_id: event.caller.id,
            # preimage detail
            call_module:,
            call_name:,
            call_params:
          )
        end
      end
    end
  end
end
