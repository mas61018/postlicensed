# Postlicensed

A tool used after [Licensed](https://github.com/github/licensed) for niche purposes

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'postlicensed', git: 'https://github.com/mas61018/postlicensed'
```

And then execute:

    $ bundle install

## Usage

```
$ bundle exec postlicensed bundle --licensed-cache-dir path/to/licensed-cache-dir > bundled-file.json
```

However, for this purpose, it is recommended to use a more specialized tool such as [rollup-plugin-license](https://github.com/mjeanroy/rollup-plugin-license) if possible.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
