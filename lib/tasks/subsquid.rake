# Get and store raw data from subsquid
namespace :subsquid do
  desc 'fetch events'
  task :fetch_events, %i[network] => :environment do |_, args|
    network = Network.find_by(name: args[:network])
    raise "Network '#{args[:network]}' not found" unless network

    # get last event sid of pallet
    last_event = SubsquidEvent.where(network:).order(sid: :desc).first
    last_event_sid = last_event&.sid || ''

    # fetch events
    subsquid_client = Object.const_get("Subsquid::#{args[:network].camelize}")
    puts "== fetch events, from_id(excluded): #{last_event_sid}, limit: 5"
    events = subsquid_client.events(SubsquidEvent.event_names, last_event_sid, 5)
    puts "#{events.length} events found"

    # save events to db
    events.each do |event|
      SubsquidEvent.create!(
        network:,
        sid: event[:id],
        index: event[:index],
        name: event[:name],
        pallet_name: event[:name].split('.')[0],
        event_name: event[:name].split('.')[1],
        args: event[:args],
        block_height: event[:block][:height],
        block_hash: event[:block][:block_hash],
        block_timestamp: event[:block][:timestamp],
        block_spec_version: event[:block][:spec_version],
        block_events: event[:block][:events],
        call_name: event[:call] && event[:call][:name],
        call_pallet_name: event[:call] && event[:call][:name].split('.')[0],
        call_call_name: event[:call] && event[:call][:name].split('.')[1],
        call_args: event[:call] && event[:call][:args],
        call_origin: event[:call] && event[:call][:origin],
        call_extrinsic_index: event[:call] && event[:call][:extrinsic_index]
      )
    end

    puts "\n"
  end

  # rails subsquid:sync_events[darwinia]
  desc 'sync events'
  task :sync_events, %i[network] => :environment do |_, args|
    loop do
      Rake::Task['subsquid:fetch_events'].reenable
      Rake::Task['subsquid:fetch_events'].invoke(args[:network])
      sleep 10
    rescue StandardError => e
      puts e.message
      puts e.backtrace
      break
    end
  end
end
