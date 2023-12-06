namespace :db do
  desc 'Rebuild dev or test database'
  task :rebuild, [] => :environment do
    raise 'Not allowed to run on production' if Rails.env.production?

    Rake::Task['db:drop'].execute
    Rake::Task['db:create'].execute
    Rake::Task['db:migrate'].execute
    Rake::Task['db:seed'].execute
  end

  desc 'Convert development DB to Rails test fixtures'
  task to_fixtures: :environment do
    tables_to_dump = %w[networks subsquid_events].freeze
    table_jsonb_columns = {
      'subsquid_events' => %w[args block_events call_args call_origin]
    }

    begin
      ActiveRecord::Base.establish_connection
      ActiveRecord::Base.connection.tables.each do |table_name|
        next unless tables_to_dump.include?(table_name)

        conter = '000'
        file_path = "#{Rails.root}/test/fixtures/#{table_name}.yml"
        File.open(file_path, 'w') do |file|
          rows = ActiveRecord::Base.connection.select_all("SELECT * FROM #{table_name}")
          jsonb_columns = table_jsonb_columns[table_name]
          data = rows.each_with_object({}) do |record, hash|
            record.each_pair do |key, value|
              record[key] = JSON.parse(value) if jsonb_columns&.include?(key) && value
            end
            suffix = record['id'].blank? ? conter.succ! : record['id']
            hash["#{table_name.singularize}_#{suffix}"] = record
          end
          puts "- writing table '#{table_name}' to '#{file_path}'"
          file.write(data.to_yaml)
        end
      end
    ensure
      ActiveRecord::Base.connection.close if ActiveRecord::Base.connection
    end
  end

  desc 'export subsquid_events table'
  task export: :environment do
    puts 'Export subsquid_events'

    # Get a file ready, the 'data' directory has already been added in Rails.root
    filepath = File.join(Rails.root, 'data', 'subsquid_events.json')
    puts "- exporting subsquid_events into #{filepath}"

    events = SubsquidEvent.all.as_json

    # The pretty is nice so I can diff exports easily, if that's not important, JSON(users) will do
    File.open(filepath, 'w') do |f|
      f.write(JSON.pretty_generate(events))
    end

    puts "- dumped #{events.size} subsquid_events"
  end

  desc 'import subsquid_events dump'
  task import: :environment do
    puts '- importing subsquid_events'

    filepath = File.join(Rails.root, 'data', 'subsquid_events.json')
    abort "Input file not found: #{filepath}" unless File.exist?(filepath)

    events = JSON.parse(File.read(filepath))

    events.each do |e|
      SubsquidEvent.create(e)
    end

    puts "- imported #{events.size} subsquid_events"
  end

  desc 'clean'
  task :clean, %i[network] => :environment do |_, args|
    puts "- cleaning tables for #{args[:network]}"
    network = Network.find_by(name: args[:network])
    [SubsquidEvent, Governance, Preimage, TreasuryProposal, DemocracyPublicProposal, CouncilMotion,
     DemocracyExternalProposal, TechcommProposal, DemocracyReferendum].each do |m|
      puts "#{m}: #{m.where(network:).delete_all}"
    end
  end
end
