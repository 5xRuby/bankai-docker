# frozen_string_literal: true

Bankai::Docker.setup do
  detect_package :database, :gem do |package|
    if pg?
      package.add_dependency 'postgresql-dev', runtime: false
      package.add_runtime_dependency 'postgresql-libs'
    end

    if mysql?
      package.add_dependency 'mariadb-dev', runtime: false
      package.add_runtime_dependency 'mariadb-client-libs'
    end
  end

  detect_package :sassc, :gem do |package|
    package.add_runtime_dependency 'libstdc++' if gem?('sassc')
  end

  detect_package :mini_magick, :gem do |package|
    package.add_runtime_dependency 'imagemagick' if gem?('mini_magick')
  end
end
