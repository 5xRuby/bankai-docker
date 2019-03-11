# frozen_string_literal: true

require 'bankai/docker'
require 'bankai/docker/builder'

config = Rails.root.join('config', 'docker.rb')
if config.exist?
  load config
else
  load Bankai::Docker::File.default
end

namespace :docker do
  load 'bankai/docker/tasks/build.rake'
end
