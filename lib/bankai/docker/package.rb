# frozen_string_literal: true

require 'singleton'

module Bankai
  module Docker
    # The package manager
    class Package
      class << self
        def use(name, &block)
          instance.switch(name, &block)
        end

        def any?(name)
          !instance.stages[name.to_sym].nil?
        end

        def command_for(name)
          format(
            instance.command,
            packages: (instance.stages[name.to_sym] || []).uniq.join(' ')
          )
        end
      end

      include Singleton

      attr_reader :stages, :command

      def initialize
        # TODO: Support more package manager
        @command = 'apk add --no-cache %<packages>s'
        @mutex = Mutex.new
        @stages = {}

        @current_stage = :main
      end

      def add_dependency(*packages, runtime: true)
        current_stage.concat(packages)
        stage(:main).concat(packages) if runtime
      end

      def add_runtime_dependency(*packages)
        stage(:main).concat(packages)
      end

      def switch(stage_name, &_block)
        prev = @current_stage
        @mutex.synchronize do
          @current_stage = stage_name.to_s
          yield self
          @current_stage = prev
        end
      end

      def current_stage
        stage(@current_stage)
      end

      def stage(name)
        name = name.to_sym
        @stages[name] ||= []
        @stages[name]
      end
    end
  end
end
