# frozen_string_literal: true

module Bankai
  module Docker
    # The docker command
    class Command
      def initialize(type, *args, options: {}, mode: nil)
        @type = type.to_s.upcase
        @args = args
        @options = options
        @mode = mode
      end

      def to_s
        "#{@type} #{options} #{args}"
      end

      # TODO: Prevent use getter as helper method name
      def args
        return @args.to_s if @mode == :array

        @args.join(' ')
      end

      def options
        @options.map do |key, value|
          "--#{key}=#{value}"
        end.compact.join(' ')
      end
    end
  end
end
