# InferredCrumpets

[![Gem Version](https://badge.fury.io/rb/inferred_crumpets.svg)](http://badge.fury.io/rb/inferred_crumpets)
[![Build Status](https://github.com/sealink/inferred_crumpets/workflows/Build%20and%20Test/badge.svg?branch=master)](https://github.com/sealink/inferred_crumpets/actions)
[![Coverage Status](https://coveralls.io/repos/github/sealink/inferred_crumpets/badge.svg?branch=master)](https://coveralls.io/github/sealink/inferred_crumpets?branch=master)

Automatic breadcrumbs for Rails. Built with [crumpet](https://github.com/blaknite/crumpet).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'inferred_crumpets'
```

And then execute:

    $ bundle

## Usage

In the view call `render_inferred_crumbs`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Release

To publish a new version of this gem the following steps must be taken.

* Update the version in the following files
  ```
    CHANGELOG.md
    lib/inferred_crumpets/version.rb
  ````
* Create a tag using the format v0.1.0
* Follow build progress in GitHub actions

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sealink/inferred_crumpets. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
