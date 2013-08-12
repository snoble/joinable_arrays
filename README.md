# JoinableArray

A small gem to make it easier to do relational joins with arrays in ruby without requiring database calls.

## Usage

```ruby
  city_building = JoinableArray.new([
    {:city => 'Paris', :building => "Eiffel Tower"},
    {:city => 'Paris', :building => "Eiffel Tower"},
    {:city => 'Moscow', :building => "St Basil's Cathedral"},
    {:city => 'Baghdad', :building => "Victory Arch"}
  ])

  city_country = JoinableArray.new([
    {:city => 'Paris', :country => "France"},
    {:city => 'Moscow', :country => "Russia"},
    {:city => 'Baghdad', :country => "Iraq"},
    {:city => 'New York', :country => "USA"}
  ])

  city_building.join_on {|x| x[:city]}
  city_country.join_on {|x| x[:city]}
  building_country = city_building.inner_join(city_country) {|cb, cc| {:building => cb[:building], :country => cc[:country]}}
```
result:
```ruby
  => [{:building=>"Victory Arch", :country=>"Iraq"}, {:building=>"St Basil's Cathedral", :country=>"Russia"}, {:building=>"Eiffel Tower", :country=>"France"}, {:building=>"Eiffel Tower", :country=>"France"}]
```

joinable_array offers a JoinableArray class which can be used as

```ruby
things1 = JoinableArray(array1)
things2 = JoinableArray(array2)

outer_join = things1
  .outer_join(things2) {|l,r| l.merge(r)}

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

The simplest join is `outer_join` which is a method on `JoinableArray` and requires another `JoinableArray` as its parameter and returns a 3rd `JoinableArray` which is the outer join of the original two `JoinableArray` instances. The elements of the returned `JoinableArray` is defined by the block passed to `outer_join`. The block accepts two parameters: the first is an element from the first `JoinableArray` and the second is from the other `JoinableArray`. The block returns the value of resulting `JoinableArray`

## Installation

Add this line to your application's Gemfile:

    gem 'joinable_array'

And then execute:

    bundle

Or install it yourself as:

    gem install joinable_array
