Bankai Docker
===

This gem is extension for [Bankai](https://github.com/5xruby/bankai) to build production ready docker image.

> By the default docker image will have size about 180MB includes Ruby, Node.js, Yarn and Required Gems for Rails

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bankai-docker'
```

Then the docker related generator and rake task will added to your project.


## Usage

This gem will try to setup Dockerfile and .dockerignore for your project, so you can direct use this Rake task to build docker image:

```
rake docker:build
```

By the default, we will use the `$(whoami)/[RAILS_APP_NAME]` as docker image ex. `5xruby/example` but you can specify it if you want

```
rake docker:build[mycompany/example]
```

If you want to use our DSL to define the Dockerfile generate, you can edit `config/docker.rb` to defined it.

```
# Generate config/docker.rb
rails generate bankai:docker:install
# Edit it
vim config/docker.rb
```

## Roadmap

* [ ] Auto detect Dockerfile
* [ ] Auto detect .dockerignore
* [x] Auto package install detect from Gemfile
* [ ] DSL
  * [ ] Gem Install
  * [ ] Specify Ruby/Node Version
  * [x] Package Install
  * [ ] Bundle / Rake / Rails Commands
  * [ ] Auto `COPY --from` rules

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/5xruby/bankai-docker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Bankai::Docker project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/5xruby/bankai-docker/blob/master/CODE_OF_CONDUCT.md).
