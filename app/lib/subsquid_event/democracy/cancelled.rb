class SubsquidEvent
  module Democracy
    module Cancelled
      class << self
        def handle(_event)
          raise '`Democracy.Cancelled` event handler not implemented'
        end
      end
    end
  end
end
