# IdentityCode

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'identitycode'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install identitycode

## Usage

This gem supports Estonian and Latvian identity codes. Just specify `EE` or `LV` class accordingly (`IdentityCode::EE` or `IdentityCode::LV`)

*NB*: Latvian identity codes don't have sex support

```ruby
> require 'identity_code'
> code = IdentityCode::EE.new('38312203720')
> code.valid?
# or
> IdentityCode::EE.valid?('38312203720')
=> true
> IdentityCode::LV.valid?('20128315289')
=> true
> IdentityCode.valid?(country: :lv, code: '20128315289')
=> true
> code.sex
=> 'M'
> code.birth_date.to_s
=> '1983-12-20'
> code.age
=> 31
# Generate random valid identity code
> IdentityCode.generate(country: :ee)
=> '37504163700'
> IdentityCode::EE.generate
=> '37504163700'
> IdentityCode::EE.generate(sex: 'M', year: 1983, month: 12, day: 20)
=> '38312209528'
> IdentityCode::LV.generate(year: 1983, month: 12, day: 20, separator: true)
=> '201283-15289'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/defeed/identitycode. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
