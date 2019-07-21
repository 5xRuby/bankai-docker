# frozen_string_literal: true

module Bankai
  module Docker
    module DSL
      # Gemfile detect
      module Gemfile
        def gem?(name)
          gemfile.match?(/^\s*gem .#{name}./)
        end

        private

        def gemfile
          @gemfile ||= ::File.read(Rails.root.join('Gemfile'))
        end
      end
    end
  end
end
