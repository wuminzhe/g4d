# == Schema Information
#
# Table name: users
#
#  id           :bigint           not null, primary key
#  address      :string
#  last_seen_at :datetime
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class User < ApplicationRecord
  has_many :identities
  before_create :seen, :set_name

  def seen
    self.last_seen_at = DateTime.now
  end

  def set_name
    self.name = "0x..#{address[-5..]}"
  end

  def identity_name(network)
    identities.find_by(network:)&.display_name || name || "0x..#{address[-5..]}"
  end
end
