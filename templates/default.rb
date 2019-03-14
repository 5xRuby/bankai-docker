# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Bankai::Docker.setup do
  runtime_package 'tzdata', 'libstdc++', 'git'

  stage :gem do
    package 'build-base', 'ca-certificates', 'zlib-dev', 'libressl-dev',
            runtime: false

    run 'mkdir -p /src/app'

    add 'Gemfile', '/src/app'
    add 'Gemfile.lock', '/src/app'

    workdir '/src/app'
    run 'bundle install --deployment --without development test ' \
        '--no-cache --clean && rm -rf vendor/bundle/ruby/**/cache'

    produce '/src/app/vendor/bundle'
    produce '/usr/local/bundle/config'
  end

  stage :node, from: 'node:10.15.2-alpine' do
    run 'mv /opt/yarn-v${YARN_VERSION} /opt/yarn'

    produce '/usr/local/bin/node'
    produce '/opt/yarn'
  end

  main do
    run 'mkdir -p /src/app'

    env 'PATH=/opt/yarn/bin:/src/app/bin:$PATH'
    env 'RAILS_ENV=production'

    add '.', '/src/app'
    workdir '/src/app'

    expose 80

    entrypoint 'docker-entrypoint'
    cmd 'serve'
  end
end
# rubocop:enable Metrics/BlockLength
