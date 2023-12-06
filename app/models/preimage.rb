# == Schema Information
#
# Table name: preimages
#
#  id            :bigint           not null, primary key
#  network_id    :integer
#  preimage_hash :string
#  created_block :integer
#  updated_block :integer
#  status        :integer
#  amount        :string
#  call_module   :string
#  call_name     :string
#  call_params   :jsonb
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :integer
#
class Preimage < ApplicationRecord
  enum status: %w[noted requested cleared]

  belongs_to :network
  belongs_to :author, class_name: 'User', foreign_key: :user_id

  # network: network model object
  # block: {
  #   block_spec_version:,
  #   block_hash:,
  #   block_height:,
  # }
  # user: user model object
  def self.create_from_raw_data(preimage_bytes, network, block, user, status = 'noted')
    preimage_hash = ScaleUtils.hash_call(preimage_bytes)
    decoded = ScaleUtils.decode_preimage(
      preimage_bytes,
      network.name,
      block[:block_hash]
    )
    Preimage.create(
      network:,
      preimage_hash:,
      created_block: block[:block_height],
      updated_block: block[:block_height],
      status:,
      user_id: user.id,
      # preimage detail
      call_module: decoded['pallet_name'],
      call_name: decoded['call_name'],
      call_params: decoded['call'].first&.[](decoded['call_name'].underscore)
    )
  end
end
