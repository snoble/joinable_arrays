# JoinableArray

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'joinable_array'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install joinable_array

## Usage

joinable_array offers a JoinableArray class which can be used as

```ruby
things1 = JoinableArray(array1)
things2 = JoinableArray(array2)
 
inner_join = things1
  .joins_on {|x| [x[0], x[1]]}
  .inner_join(things2.joins_on {|x| [x.a, x.b]}) {|l,r| l.merge(r)}
 
left_join = things1
  .joins_on {|x| [x[0], x[1]]}
  .fills_with {|key| key[0 .. -1].concat([0,0,0])}
  .left_join(things2.joins_on {|x| [x.a, x.b]}) {|l,r| l.merge(r)}
 
right_join = things1
  .joins_on {|x| [x[0], x[1]]}
  .right_join(things2
    .joins_on {|x| [x.a, x.b]}
    .fills_with {|key|, Obj.new(*key)}
  ) {|l,r| l.merge(r)}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
=======
joinable_arrays
===============
