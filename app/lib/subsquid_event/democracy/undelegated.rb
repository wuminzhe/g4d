class SubsquidEvent
  module Democracy
    module Undelegated
      class << self
        def handle(_event)
          raise '`Democracy.Undelegated` event handler not implemented'
        end
      end
    end
  end
end
