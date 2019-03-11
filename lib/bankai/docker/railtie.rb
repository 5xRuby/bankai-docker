# frozen_string_literal: true

require 'rails/railtie'

module Bankai
  module Docker
    # :nodoc:
    class Railtie < Rails::Railtie
      rake_tasks do
        load 'bankai/docker/tasks/all.rake'
      end
    end
  end
end
