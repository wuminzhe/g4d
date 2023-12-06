# == Schema Information
#
# Table name: discussions
#
#  id                   :bigint           not null, primary key
#  uuid                 :string
#  title                :string
#  body                 :text
#  network_id           :integer
#  first_real_step_type :string
#  first_real_step_key  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class Discussion < ApplicationRecord
  acts_as_commentable
  belongs_to :network

  before_create :init_uuid

  def init_uuid
    self.uuid = SecureRandom.uuid
  end
end
