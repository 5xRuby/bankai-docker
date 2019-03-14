# frozen_string_literal: true

require 'singleton'

module Bankai
  module Docker
    # The generated files copy manager
    class Copy
      include Singleton

      class << self
        def add(stage, source, destination)
          instance.add(stage, source, destination)
        end

        def to_s
          instance.to_s
        end
      end

      def initialize
        @items = {}
      end

      def add(stage, source, destination)
        stage = stage.to_sym
        @items[stage] ||= []
        @items[stage] << [source, destination]
      end

      def to_s
        @items.flat_map do |stage, items|
          items.uniq.map do |source, destination|
            "COPY --from=#{stage} #{source} #{destination}"
          end
        end.join("\n")
      end
    end
  end
end
