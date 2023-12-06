class SubsquidEvent
  module Democracy
    module Delegated
      class << self
        def handle(_event)
          raise '`Democracy.Delegated` event handler not implemented'
        end
      end
    end
  end
end
