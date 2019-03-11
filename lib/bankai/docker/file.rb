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

        def stages
          instance.stages
        end

        def default
          root = Bankai::Docker::Generators::Base.default_source_root
          "#{root}/default.rb"
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
        @stages = @stages.sort_by { |_, stage| stage.index }.to_h
      end

      def main(from: nil, &block)
        @stages[:main] = Stage.new(:main, from: from, &block)
      end

      def ensure_name
        return @name unless @name.nil?

        app_name = Rails.app_class.parent_name.demodulize.underscore.dasherize
        default_name = "#{`whoami`.chomp}/#{app_name}"
        print "Docker Image Name (#{default_name}) > "
        input = STDIN.gets.chomp
        @name = default_name
        @name = input unless input.empty?
        @name
      end

      def to_s
        root = Bankai::Docker::Generators::Base.default_source_root
        template = ERB.new(::File.read("#{root}/dockerfile.erb"), nil, '-')
        template.result(binding)
      end
    end
  end
end
