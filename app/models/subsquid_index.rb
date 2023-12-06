# == Schema Information
#
# Table name: subsquid_indices
#
#  id         :bigint           not null, primary key
#  name       :string
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class SubsquidIndex < ApplicationRecord
  def self.get(name)
    (find_by_name(name) || create!(name:, value: '')).value
  end

  def self.set(name, value)
    find_by_name(name)&.update!(value:)
  end

  [:processed_darwinia_event_sid].each do |name|
    define_singleton_method(name) do
      get(name)
    end
    define_singleton_method("#{name}=") do |value|
      set(name, value)
    end
  end
end
