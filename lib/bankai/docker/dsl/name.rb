# frozen_string_literal: true

module Bankai
  module Docker
    module DSL
      # Argument Support
      module Name
        def name(new_name = nil)
          return @name if new_name.nil?

          @name = new_name
        end
      end
    end
  end
end
