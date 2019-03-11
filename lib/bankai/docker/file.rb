# frozen_string_literal: true

require 'singleton'

module Bankai
  module Docker
    # Docker File generator
    class File
      class << self
        def setup(&block)
          instance.reset
          instance.setup(&block)
        end

        def name
          instance.name
        end

        def print
          instance.to_s
        end
      end

      include Singleton
      include DSL::Name
      include DSL::Argument

      attr_reader :stages

      def initialize
        reset
      end

      def setup(&block)
        instance_eval(&block)
      end

      def reset
        @name = nil
        @stages = {}
        @arguments = {}
      end

      def stage(name, from: nil, &block)
        name = name.to_sym
        @stages[name] = Stage.new(name, from: from, &block)
      end

      def main(from: nil, &block)
        @stages[:main] = Stage.new(:main, from: from, &block)
      end

      def to_s
        root = Bankai::Docker::Generators::Base.default_source_root
        template = ERB.new(::File.read("#{root}/dockerfile.erb"), nil, '-')
        template.result(binding)
      end
    end
  end
end
