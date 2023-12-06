namespace :identity do
  desc 'update display names'
  task :update_display_names, %i[network] => :environment do |_, args|
    network = Network.find_by(name: args[:network])
    raise "Network '#{args[:network]}' not found" unless network

    User.all.each do |user|
      identity_name = AccountHelper.get_identity_dispaly_name(network.name, user.address)
      puts "#{user.address}: #{identity_name}"
      if identity_name
        identity = Identity.find_or_create_by(user:, network:)
        identity.update(display_name: identity_name) if identity.display_name != identity_name
      end
    end
  end
end
