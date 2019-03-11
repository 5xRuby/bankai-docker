# frozen_string_literal: true

module Bankai
  module Docker
    # The docker command
    class Command
      def initialize(type, *args, options: {})
        @type = type.to_s.upcase
        @args = args
        @options = options
      end

      def to_s
        "#{@type} #{options} #{@args.join(' ')}"
      end

      def options
        @options.map do |key, value|
          "--#{key}=#{value}"
        end.compact.join(' ')
      end
    end
  end
end
