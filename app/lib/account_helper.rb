module AccountHelper
  class << self
    def get_identity_dispaly_name(network_name, address)
      body = JSON.parse Faraday.get(identity_url(network_name, address)).body

      body['result']['info']['display']&.first&.last&.to_bytes&.to_utf8 if body['code'] == 0
    end

    def identity_url(network_name, address)
      "https://api.darwinia.network/#{network_name}/identity/identity_of/#{address}"
    end
  end
end

# puts AccountHelper.get_identity_name('crab', '0x0a1287977578F888bdc1c7627781AF1cc000e6ab')
