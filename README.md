# InferredCrumpets

[![Build Status](https://travis-ci.org/sealink/inferred_crumpets.svg?branch=master)](https://travis-ci.org/sealink/inferred_crumpets)

Automatic breadcrumbs for Rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'inferred_crumpets'
```

And then execute:

    $ bundle

## Usage

Basic usage:

```ruby
class ApplicationController
  crumbs do
    add_crumb "Home", root_path
  end
end

class WidgetsController < ApplicationController
  before_action :load_widget
  before_action :load_parent

  infer_crumbs_for :widget, through: :parent_widget

  private

  def load_widget
    @widget = Widget.find(params[:id])
  end

  def load_parent
    @parent_widget = @widget.parent_widget
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sealink/inferred_crumpets. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
