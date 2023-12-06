require 'scale_rb'

RPC_DICT = {
  darwinia: 'https://rpc.darwinia.network',
  crab: 'https://crab-rpc.darwinia.network',
  pangolin: 'https://pangolin-rpc.darwinia.network',
  pangoro: 'https://pangoro-rpc.darwinia.network'
}.freeze

module ScaleUtils
  def self.decode_preimage(preimage_bytes_str, network_name, block_hash)
    metadata = ScaleRb::HttpClient.get_metadata_cached(
      RPC_DICT[network_name.to_sym],
      at: block_hash,
      dir: File.join(__dir__, 'metadata')
    )
    decoded_preimage = Metadata.decode_call(preimage_bytes_str.to_bytes, metadata).to_json
    JSON.parse(decoded_preimage)
  end

  def self.hash_call(bytes_str)
    Hasher.blake2_256(bytes_str.to_bytes).to_hex
  end
end
