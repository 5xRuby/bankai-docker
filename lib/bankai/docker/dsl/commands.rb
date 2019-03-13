# frozen_string_literal: true

module Bankai
  module Docker
    module DSL
      # General Command
      module Commands
        def run(*commands)
          command 'run', *commands
        end

        def workdir(dir)
          command 'workdir', dir
        end

        def env(env)
          command 'env', env
        end

        def add(from, to)
          command 'add', from, to
        end

        def copy(source, destination, from: nil)
          command 'copy', source, destination, options: { from: from }
        end

        def expose(*ports)
          ports.each do |port|
            command 'expose', port
          end
        end

        def entrypoint(*params)
          command 'entrypoint', *params, mode: :array
        end

        def cmd(*params)
          command 'cmd', *params, mode: :array
        end

        def volume(*volumes)
          command 'volume', *volumes, mode: :array
        end

        def package(*packages, runtime: true)
          Package.use(@name) do |instance|
            instance.add_dependency(*packages, runtime: runtime)
          end
        end

        def runtime_package(*packages)
          Package.instance.add_runtime_dependency(*packages)
        end

        def package_command
          return unless Package.any?(@name)

          "RUN #{Package.command_for @name}"
        end
      end
    end
  end
end
