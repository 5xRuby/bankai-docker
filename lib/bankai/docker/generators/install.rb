# frozen_string_literal: true

require_relative 'base'

module Bankai
  module Docker
    module Generators
      # :nodoc:
      class InstallGenerator < Base
        def setup_config
          template 'default.rb', 'config/docker.rb'
        end
      end
    end
  end
end
