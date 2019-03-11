# frozen_string_literal: true

module Bankai
  module Docker
    # The multistage
    class Stage
      class << self
        attr_reader :index

        def next_index
          @index ||= 0
          @index += 1
        end
      end

      include DSL::Name
      include DSL::Argument
      include DSL::Commands

      attr_reader :name, :index

      def initialize(name, from: nil, &block)
        @name = name
        @from = from || "ruby:#{RUBY_VERSION}-alpine"
        @index = main? ? 999 : Stage.next_index
        @commands = []
        @arguments = {}
        instance_eval(&block)
      end

      def main?
        name == :main
      end

      def from(new_value = nil)
        return @from if new_value.nil?

        @from = new_value
      end

      def command(type, *arguments)
        @commands << Command.new(type, *arguments)
      end

      def to_s
        root = Bankai::Docker::Generators::Base.default_source_root
        template = ERB.new(::File.read("#{root}/stage.erb"), nil, '-')
        template.result(binding)
      end
    end
  end
end