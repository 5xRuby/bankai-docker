# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Bankai::Docker.setup do
  stage :gem do
    package 'build-base', 'ca-certificates', 'zlib-dev', 'libressl-dev',
            runtime: false

    run 'mkdir -p /src/app'

    add 'Gemfile', '/src/app'
    add 'Gemfile.lock', '/src/app'

    workdir '/src/app'
    run 'bundle install --deployment --without development test ' \
        '--no-cache --clean && rm -rf vendor/bundle/ruby/**/cache'
  end

  stage :node, from: 'node:10.15.2-alpine' do
    run 'mv /opt/yarn-v${YARN_VERSION} /opt/yarn'
  end

  main do
    # Requirements
    # node - libstdc++
    # yarn - git
    runtime_package 'tzdata', 'libstdc++', 'libcurl', 'git'
    run 'mkdir -p /src/app'

    copy '/usr/local/bin/node', '/usr/local/bin/', from: :node
    copy '/opt/yarn', '/opt/yarn', from: :node

    env 'PATH=/opt/yarn/bin:/src/app/bin:$PATH'

    add '.', '/src/app'

    copy '/src/app/vendor/bundle', '/src/app/vendor/bundle', from: :gem
    copy '/usr/local/bundle/config', '/usr/local/bundle/config', from: :gem

    workdir '/src/app'

    env 'RAILS_ENV=production'
    run 'rails app:update:bin && rm -rf /src/app/tmp'

    expose 80

    entrypoint './bin/docker-entrypoint'
    cmd 'serve'
  end
end
# rubocop:enable Metrics/BlockLength
