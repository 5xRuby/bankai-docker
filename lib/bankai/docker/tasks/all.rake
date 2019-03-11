# frozen_string_literal: true

require 'bankai/docker'

load Rails.root.join('config', 'docker.rb')

namespace :docker do
  load 'bankai/docker/tasks/build.rake'
end
