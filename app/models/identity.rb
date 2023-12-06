# == Schema Information
#
# Table name: identities
#
#  id           :bigint           not null, primary key
#  user_id      :integer
#  network_id   :integer
#  display_name :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Identity < ApplicationRecord
  belongs_to :user
  belongs_to :network
end
