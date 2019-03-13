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

      def package(stage, *packages, runtime: true)
        Package.use(stage) do |instance|
          instance.add_dependency(*packages, runtime: runtime)
        end
      end

      def runtime_package(*packages)
        Package.instance.add_runtime_dependency(*packages)
      end

      def update_name(default = nil)
        app_name = Rails.app_class.parent_name.demodulize.underscore.dasherize
        @name = @name || default || "#{`whoami`.chomp}/#{app_name}"
      end

      def to_s
        root = Bankai::Docker::Generators::Base.default_source_root
        template = ERB.new(::File.read("#{root}/dockerfile.erb"), nil, '-')
        template.result(binding)
      end
    end
  end
end
