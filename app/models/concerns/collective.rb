module Collective
  extend ActiveSupport::Concern

  included do
    def self.last_before(before_block_height, network_id, condition = '', condition_params = [])
      query = self.where("network_id=? and created_block<?", network_id, before_block_height)

      if condition != ''
        query = query.where(condition, *condition_params)
      end

      query.last
    end
  end
end
