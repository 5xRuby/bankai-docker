# frozen_string_literal: true

module Bankai
  module Docker
    module DSL
      # Argument Support
      module Argument
        def argument(name, default = nil)
          @arguments ||= {}
          name = sanitize_argument(name.to_s)
          @arguments[name] = default
        end

        private

        def sanitize_argument(name)
          name = name.dup
          name.gsub!(/\s/, '_')
          name.gsub!(/[^\w]/, '')
          name.upcase!
        end
      end
    end
  end
end
