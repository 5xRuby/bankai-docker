# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Bankai::Docker.setup do
  argument :passenger_version, '6.0.2'

  stage :nginx do
    # TODO: Auto load global argument?
    argument :passenger_version

    run 'apk add --no-cache build-base curl ca-certificates',
        'zlib-dev curl-dev libressl-dev linux-headers'
    # TODO: Implement workdir {}
    run 'mkdir /src'
    workdir '/src'
    # TODO: Implement gem DSL
    run 'gem install rack'
    # TODO: Support Hash
    env 'PATH=/src/passenger-${PASSENGER_VERSION}/bin:$PATH'

    # TODO: Support && mode
    run 'curl -SLO http://s3.amazonaws.com/phusion-passenger/' \
        'releases/passenger-${PASSENGER_VERSION}.tar.gz &&',
        'tar -zxvf passenger-${PASSENGER_VERSION}.tar.gz &&',
        'rm passenger-${PASSENGER_VERSION}.tar.gz'

    run 'passenger-install-nginx-module --prefix=/opt/nginx' \
        ' --languages=ruby --auto --auto-download'
    run 'sed -i \'s/root\s*html/root \/src\/app\/public/g\' ' \
        '/opt/nginx/conf/nginx.conf'
    run 'sed -i \'s/^\(\(\s*\)server_name\s*localhost;\)/' \
        '\1\n\2passenger_enabled on;/g\' /opt/nginx/conf/nginx.conf'
    run 'sed -i \'s/#user\(\s*\)nobody/daemon off;' \
        '\nuser\1www-data/g\' /opt/nginx/conf/nginx.conf'
    run 'sed -i \'s/\(worker_processes\s*\)\d*/' \
        '\1auto/g\' /opt/nginx/conf/nginx.conf'
  end

  stage :gem do
    run 'apk add --no-cache build-base ca-certificates zlib-dev',
        'libressl-dev postgresql-dev'

    run 'mkdir -p /src/app'

    add 'Gemfile', '/src/app'
    add 'Gemfile.lock', '/src/app'

    run 'cd /src/app && bundle install --deployment'
  end

  stage :node, from: 'node:10.15.2-alpine' do
    run 'mv /opt/yarn-v${YARN_VERSION} /opt/yarn'
  end

  main do
    argument :passenger_version

    run 'apk add --no-cache tzdata postgresql-libs libstdc++ libcurl git'
    run 'mkdir -p /src/app'

    copy '/opt/nginx', '/opt/nginx', from: :nginx
    copy '/src/passenger-${PASSENGER_VERSION}',
         '/src/passenger-${PASSENGER_VERSION}', from: :nginx
    copy '/usr/local/bin/node', '/usr/local/bin/', from: :node
    copy '/usr/local/lib/node_modules',
         '/usr/local/lib/node_modules', from: :node
    copy '/opt/yarn', '/opt/yarn', from: :node

    env 'PATH=/opt/nginx/sbin:/opt/yarn/bin:/src/app/bin:$PATH'

    add '.', '/src/app'

    copy '/src/app/vendor/bundle', '/src/app/vendor/bundle', from: :gem
    copy '/usr/local/bundle/config', '/usr/local/bundle/config', from: :gem

    workdir '/src/app'

    run './bin/rails app:update:bin'

    env 'RAILS_ENV=production'

    run 'yarn install'
    run 'rake assets:precompile'

    run 'addgroup -S www-data &&',
        'adduser -S www-data www-data &&',
        'chown -R www-data /src/app'
  end
end
# rubocop:enable Metrics/BlockLength
