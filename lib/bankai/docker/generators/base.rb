# frozen_string_literal: true

require 'bankai/generators/base'

module Bankai
  module Docker
    module Generators
      # :nodoc:
      class Base < Bankai::Generators::Base
        def self.default_source_root
          ::File.expand_path(
            ::File.join('..', '..', '..', '..', 'templates'),
            __dir__
          )
        end
      end
    end
  end
end
