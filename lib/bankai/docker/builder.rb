# frozen_string_literal: true

module Bankai
  module Docker
    # The Rake Builder task
    class Builder
      include Rake::DSL if defined? Rake::DSL

      class << self
        def install_tasks
          new.install
        end
      end

      def initialize
        @name = File.name
        @layers = File.stages.map(&:first)
        @dockerfile = Tempfile.new('Dockerfile')

        setup_dockerfile
      end

      def install
        namespace(:build) { install_build_tasks }
        desc 'Build docker image'
        task build: @layers.map { |name| "build:#{name}" }
      end

      def setup_dockerfile
        @dockerfile.write File.print
        @dockerfile.rewind
      end

      private

      def cache_options
        @cache_options ||= @layers.map do |target|
          "--cache-from #{@name}:#{target}"
        end.join(' ')
      end

      def install_build_tasks
        @layers.each do |target|
          stage = File.stages[target]
          task target do
            sh command(stage)
          end
        end
      end

      def command(stage)
        [
          'docker build',
          cache_options,
          stage.main? ? '' : "--target #{stage.name}",
          "-t #{stage.tag}",
          '-f - .',
          "< #{@dockerfile.path}"
        ].join(' ')
      end
    end
  end
end
