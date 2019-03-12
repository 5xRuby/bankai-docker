# frozen_string_literal: true

module Bankai
  module Docker
    # The Rake Builder task
    class Builder
      include Rake::DSL if defined? Rake::DSL

      IGNORES = ['.git', 'node_modules', 'log/*',
                 'tmp/*', 'public/system', 'public/uploads'].freeze

      class << self
        def install_tasks
          new.install
        end
      end

      def initialize
        # TODO: Load name when running task
        @name = File.name
        @layers = File.stages.map(&:first)
        @entrypoint = Tempfile.new('docker-entrypoint')
        @dockerfile = Tempfile.new('Dockerfile')
        @dockerignore = Tempfile.new('.dockerignore')
        @dockerignore_generated = false

        setup_entrypoint
        setup_dockerfile
        setup_dockerignore

        at_exit { clear_up }
      end

      def install
        namespace(:build) { install_build_tasks }
        desc 'Build docker image'
        task :build, [:name] => @layers.map { |name| "build:#{name}" }
      end

      def setup_entrypoint
        root = Bankai::Docker::Generators::Base.default_source_root
        template = ERB.new(::File.read("#{root}/entrypoint.erb"), nil, '-')
        @entrypoint.write template.result
        @entrypoint.rewind
        path = Rails.root.join('bin', 'docker-entrypoint')
        FileUtils.cp(@entrypoint.path, path)
        FileUtils.chmod 'u+x', path
      end

      def setup_dockerfile
        @dockerfile.write File.print
        @dockerfile.rewind
      end

      def setup_dockerignore
        # TODO: Provide DSL to generate it
        ignore_file = Rails.root.join('.dockerignore')
        return if ignore_file.exist?

        @dockerignore.write IGNORES.join("\n")
        @dockerignore.rewind
        FileUtils.cp(@dockerignore.path, ignore_file)
        @dockerignore_generated = true
      end

      def clear_up
        entrypoint = Rails.root.join('bin', 'docker-entrypoint')
        entrypoint.unlink if entrypoint.exist?

        ignore_file = Rails.root.join('.dockerignore')
        return unless ignore_file.exist?
        return unless @dockerignore_generated

        ignore_file.unlink
      end

      private

      def cache_options
        @cache_options = @layers.map do |target|
          "--cache-from #{@name}:#{target}"
        end.join(' ')
      end

      def install_build_tasks
        @layers.each do |target|
          stage = File.stages[target]
          task target, :name do |_, args|
            File.instance.update_name(args[:name])
            @name ||= File.name
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
