# frozen_string_literal: true

module Bankai
  module Docker
    module DSL
      # Gemfile detect
      module Gemfile
        def pg?
          gemfile.match?(/gem .pg./)
        end

        def mysql?
          gemfile.match?(/gem .mysql2./)
        end

        def gem?(name)
          gemfile.match?(/gem .#{name}./)
        end

        private

        def gemfile
          @gemfile ||= ::File.read(Rails.root.join('Gemfile'))
        end
      end
    end
  end
end
