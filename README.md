# Virtus::Mapper

Mapper for Virtus attributes

NOTE: Recent commits allow for mixing in Virtus modules to Virtus object instances, which is a break from recommended Virtus usage.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'virtus-mapper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install virtus-mapper

## Usage

In your Virtus attributes, set the `:from` option to a symbol to translate keys
on object initialization. In the example below, `:surname` gets translated into
`:last_name`. If the `:from` option is set to an object that
`respond_to?(:call)`, the object will be called and passed the attributes hash.

```ruby
class Person
  include Virtus.model
  include Virtus::Mapper

  attribute :first_name, String
  attribute :last_name, String, from: :surname
  attribute :address,
            String,
            default: '',
            from: lambda { |atts| atts[:address][:street] rescue '' }
end

person = Person.new({ first_name: 'John',
                      surname: 'Doe',
                      address: { 'street' => '1122 Boogie Avenue' } })
person.first_name # => 'John'
person.last_name # => 'Doe'
person.address # => '1122 Boogie Avenue'
person.surname # => NoMethodError
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/virtus-mapper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
