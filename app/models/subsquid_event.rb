# == Schema Information
#
# Table name: subsquid_events
#
#  id                   :bigint           not null, primary key
#  network_id           :integer
#  sid                  :string
#  index                :string
#  name                 :string
#  pallet_name          :string
#  event_name           :string
#  args                 :jsonb
#  block_height         :integer
#  block_hash           :string
#  block_timestamp      :string
#  block_spec_version   :integer
#  block_events         :jsonb
#  call_name            :string
#  call_pallet_name     :string
#  call_call_name       :string
#  call_args            :jsonb
#  call_origin          :jsonb
#  call_extrinsic_index :string
#  call_extrinsic_hash  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class SubsquidEvent < ApplicationRecord
  belongs_to :network

  class << self
    attr_reader :event_callbacks

    # Add `handle` function to SubsquidEvent class
    # The `callback` param is an optional lambda,
    # if not given, the default callback will be used
    # to call the handler defined in lib/subsquid_event/*.rb.
    def handle(event_name, callback = nil)
      # check if the handler exists
      path = Rails.root.join('app', 'lib', 'subsquid_event', "#{event_name.split('.').map(&:underscore).join('/')}.rb")
      raise "Handler for `#{event_name}` not found" unless File.exist?(path)

      @event_callbacks ||= {}
      @event_callbacks[event_name] =
        callback ||
        lambda { |event|
          begin
            handler = SubsquidEvent.const_get(event.name.gsub('.', '::'))
            handler.handle(event)
          rescue NameError => e
            if e.message =~ /uninitialized constant SubsquidEvent::#{event.name.split('.')[0]}/
              raise "No handler found for event `#{event.name}`"
            end

            raise e
          end
        }
    end

    # Used by lib/subsquid.rb to query events
    def event_names
      @event_callbacks.keys
    end
  end

  # https://github.com/paritytech/substrate/tree/polkadot-v0.9.43
  # The handlers are defined in lib/subsquid_event/*.rb
  handle 'Preimage.Noted'
  handle 'Preimage.Requested'
  handle 'Preimage.Cleared'
  handle 'Treasury.Proposed'
  handle 'Treasury.Rejected'
  handle 'Council.Proposed'
  handle 'Council.Voted'
  handle 'Council.Disapproved'
  handle 'Council.Approved'
  handle 'Council.Closed'
  handle 'Council.Executed'
  handle 'TechnicalCommittee.Proposed'
  handle 'TechnicalCommittee.Voted'
  handle 'TechnicalCommittee.Disapproved'
  handle 'TechnicalCommittee.Approved'
  handle 'TechnicalCommittee.Closed'
  handle 'TechnicalCommittee.Executed'
  # handle 'Democracy.Delegated'
  # handle 'Democracy.Undelegated'
  # handle 'Democracy.MetadataCleared'
  # handle 'Democracy.MetadataSet'
  # handle 'Democracy.MetadataTransfered'
  handle 'Democracy.ExternalTabled'
  handle 'Democracy.Vetoed'
  handle 'Democracy.Blacklisted'
  handle 'Democracy.NotPassed'
  handle 'Democracy.Cancelled'
  handle 'Democracy.Passed'
  handle 'Democracy.ProposalCanceled'
  handle 'Democracy.Proposed'
  handle 'Democracy.Seconded'
  handle 'Democracy.Started'
  handle 'Democracy.Tabled'
  handle 'Democracy.Voted'

  after_create do |event|
    Rails.logger.info("Event: #{event.name} - #{event.sid}")
    puts "Event: #{event.name} - #{event.sid}"
    event_callback = SubsquidEvent.event_callbacks[event.name]
    raise "No callback registered for event #{event.name}" unless event_callback

    event_callback.call(event)
  end

  def caller
    return if call_origin.nil?

    kind = call_origin['__kind']
    value_kind = call_origin['value']['__kind']
    address =
      if kind == 'system' && value_kind == 'Signed'
        call_origin['value']['value']
      elsif kind == 'system' && value_kind == 'Root'
        Hasher.blake2_256('Root'.bytes).to_hex[0..41]
      else
        raise "Unknown origin kind: #{kind}, value_kind: #{value_kind}"
      end

    User.create_or_find_by(address:)
  end
end
