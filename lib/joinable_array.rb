class RelationalMethods
  def self.join(left_a, right_a, keys, options = {})
    return left_a.slice(0,0) if left_a.size == 0
    left, right = left_and_right(left_a, right_a, keys, options[:use_instance_methods])
    anchor = 0
    new_array = left_a.slice(0,0)
    left.each do |left_hash|
      right_hash = right[anchor]
      while right_hash && (right_hash[:keys] <=> left_hash[:keys]) < 0
        right_hash = right[anchor += 1]
      end
      idx = anchor
      while right_hash && right_hash[:keys] == left_hash[:keys]
        new_array << yield(left_hash[:object], right_hash[:object])
        right_hash = right[idx += 1]
      end
    end
    new_array
  end

  def self.fill_cube(left_a, right_a, keys, options = {})
    left, right, left_keys, right_keys = left_and_right(left_a, right_a, keys, options[:use_instance_methods])
    right_hash = right[idx = 0]
    new_array = left_a.slice(0, left_a.size)
    previously_added = nil
    left.each do |left_hash|
      while right_hash && (right_hash[:keys] <=> left_hash[:keys]) < 0
        if !previously_added || (right_hash[:keys] <=> previously_added) > 0
          previously_added = right_hash[:keys] 
          new_array << yield(*right_hash[:keys], right_keys)
        end
        right_hash = right[idx += 1]
      end
      while right_hash && right_hash[:keys] == left_hash[:keys]
        right_hash = right[idx += 1]
      end
    end
    while right_hash
      if !previously_added || (right_hash[:keys] <=> previously_added) > 0
        previously_added = right_hash[:keys] 
        new_array << yield(*right_hash[:keys], right_keys)
      end
      right_hash = right[idx += 1]
    end
    new_array
  end

  def self.cross_join(left_a, right_a, options = {}, &block)
    join(left_a, right_a, [], &block)
  end

  def self.left_and_right(left_a, right_a, keys, use_send = false)
    if keys.is_a?(Array)
      left_keys = keys
      right_keys = keys
    else
      left_keys = []
      right_keys = []
      keys.each do |key|
        left_keys << key[0]
        right_keys << key[1]
      end
    end
    left = left_a.map {|x| {:keys => left_keys.map {|key| use_send ? x.send(key) : x[key]}, :object => x}}
      .sort_by {|x| x[:keys]}
    right = right_a.map {|x| {:keys => right_keys.map {|key| use_send ? x.send(key) : x[key]}, :object => x}}
      .sort_by {|x| x[:keys]}
    [left, right, left_keys, right_keys]
  end
end

module JoinableWithHashes
  def inner_join(that, keys)
    RelationalMethods.join(self, that, keys, {:use_instance_methods => false}) {|l,r| l.merge(r)}
  end

  def cross_join(that)
    RelationalMethods.cross_join(self, that, {:use_instance_methods => false}) {|l,r| l.merge(r)}
  end

  def fill_cube(that, keys, default)
    RelationalMethods.fill_cube(self, that, keys, {:use_instance_methods => false}) do |*values, keys|
      Hash[keys.zip(values)].merge(default)
    end
  end

  def left_join(that, keys, default)
    inner_join(that.fill_cube(self, keys, default), keys)
  end

  def right_join(that, keys, default)
    fill_cube(that, keys, default).inner_join(that, keys)
  end
end

module JoinableWithArrays
  def inner_join(that, keys)
    RelationalMethods.join(self, that, keys, {:use_instance_methods => false}) {|l,r| l.slice(0, l.size).concat(r)}
  end

  def cross_join(that)
    RelationalMethods.cross_join(self, that, {:use_instance_methods => false}) {|l,r| l.slice(0, l.size).concat(r)}
  end

  def fill_cube(that, keys, default)
    RelationalMethods.fill_cube(self, that, keys, {:use_instance_methods => false}) do |*values, keys|
      x = default.slice(0, default.size)
      keys.zip(values).each {|key, value| x[key] = value}
      x
    end
  end

  def left_join(that, keys, default)
    inner_join(that.fill_cube(self, keys, default), keys)
  end

  def right_join(that, keys, default)
    fill_cube(that, keys, default).inner_join(that, keys)
  end
end

module Joinable
  def inner_join(that, keys, &block)
    RelationalMethods.join(self, that, keys, {:use_instance_methods => true}, &block)
  end

  def cross_join(that, &block)
    RelationalMethods.cross_join(self, that, {:use_instance_methods => true}, &block)
  end

  def fill_cube(that, keys, &block)
    RelationalMethods.fill_cube(self, that, keys, {:use_instance_methods => true}, &block)
  end
end

class JoinableArrayOfHashes < Array
  include JoinableWithHashes
end

class JoinableArrayOfArrays < Array
  include JoinableWithArrays
end

class JoinableArray < Array
  include Joinable
end

puts "examples for JoinableArrayOfHashes"

def typeA(a,b,c,d)
  {:a => a, :b => b, :c => c, :d => d}
end

def typeB(a,b,e,f)
  {:a => a, :b => b, :e => e, :f => f}
end

a = JoinableArrayOfHashes.new([typeA(4,6,1,2), typeA(7,7,2,2), typeA(8,3,5,5), typeA(9,4,1,7)])
b = JoinableArrayOfHashes.new([typeB(8,3,1,2), typeB(8,3,2,2), typeB(7,7,5,5), typeB(1,2,3,4)])

puts "first join test"
c = a.inner_join(b, [:a, :b])
c.each {|x| puts "#{x[:a]} #{x[:b]} #{x[:c]} #{x[:d]} #{x[:e]} #{x[:f]}"}

puts "first fill_cube test"
c = a.fill_cube(b, [:a, :b], {:c => 'cc', :d => 'dd'})
c.each {|x| puts "#{x[:a]} #{x[:b]} #{x[:c]} #{x[:d]}"}

puts "second fill_cube test"
c = b.fill_cube(a, [:a, :b], {:e => 'cc', :f => 'dd'})
c.each {|x| puts "#{x[:a]} #{x[:b]} #{x[:e]} #{x[:f]}"}

puts "cross join test"
c = a.cross_join(b)
c.each {|x| puts "#{x[:a]} #{x[:b]} #{x[:c]} #{x[:d]} #{x[:e]} #{x[:f]}"}

puts "left join test"
c = a.left_join(b, [:a, :b], {:e => 'cc', :f => 'dd'})
c.each {|x| puts "#{x[:a]} #{x[:b]} #{x[:c]} #{x[:d]} #{x[:e]} #{x[:f]}"}

puts "right join test"
c = a.right_join(b, [:a, :b], {:c => 'cc', :d => 'dd'})
c.each {|x| puts "#{x[:a]} #{x[:b]} #{x[:c]} #{x[:d]} #{x[:e]} #{x[:f]}"}

puts "examples for JoinableArray"

typeA = Struct.new(:a, :b, :c, :d)
typeB = Struct.new(:a, :b, :e, :f)

a = JoinableArray.new([typeA.new(4,6,1,2), typeA.new(7,7,2,2), typeA.new(8,3,5,5), typeA.new(9,4,1,7)])
b = JoinableArray.new([typeB.new(8,3,1,2), typeB.new(8,3,2,2), typeB.new(7,7,5,5), typeB.new(1,2,3,4)])

class JoinedObject
  def initialize(left, right)
    @left = left
    @right = right
  end
  
  def method_missing(meth, *args, &block)
    return @left.send(meth, *args, &block) if @left.respond_to?(meth)
    return @right.send(meth, *args, &block) if @right.respond_to?(meth)
    return super(meth, *args, &block)
  end

  def respond_to?(meth)
    @left.respond_to?(meth) || @right.respond_to?(meth)
  end
end

puts "first join test"
c = a.inner_join(b, [:a, :b]) {|l,r| JoinedObject.new(l,r)}
c.each {|x| puts "#{x.a} #{x.b} #{x.c} #{x.d} #{x.e} #{x.f}"}

puts "first fill_cube test"
c = a.fill_cube(b, [:a, :b]) {|a,b| typeA.new(a, b, 'cc', 'dd')}
c.each {|x| puts "#{x.a} #{x.b} #{x.c} #{x.d}"}

puts "second fill_cube test"
c = b.fill_cube(a, {:e => :c, :f => :d}) {|e,f| typeB.new('aa', 'bb', e, f)}
c.each {|x| puts "#{x.a} #{x.b} #{x.e} #{x.f}"}

puts "cross join test"
c = a.cross_join(b) {|l,r| JoinedObject.new(l,r)}
c.each {|x| puts "#{x.a} #{x.b} #{x.c} #{x.d} #{x.e} #{x.f}"}

puts "examples for JoinableArrayOfArrays"

a = JoinableArrayOfArrays.new([[4,6,1,2], [7,7,2,2], [8,3,5,5], [9,4,1,7]])
b = JoinableArrayOfArrays.new([[8,3,1,2], [8,3,2,2], [7,7,5,5], [1,2,3,4]])

puts "first join test"
c = a.inner_join(b, [0, 1])
c.each {|x| puts x.join(' ')}

puts "first fill_cube test"
c = a.fill_cube(b, [0, 1], [0,1,'aa','bb'])
c.each {|x| puts x.join(' ')}

puts "second fill_cube test"
c = b.fill_cube(a, [0, 1], [0,1,'cc','dd'])
c.each {|x| puts x.join(' ')}

puts "cross join test"
c = a.cross_join(b)
c.each {|x| puts x.join(' ')}

puts "left join test"
c = a.left_join(b, [0, 1], [0, 1, 'ee', 'ff'])
c.each {|x| puts x.join(' ')}

puts "right join test"
c = a.right_join(b, [0, 1], [0, 1, 'cc', 'dd'])
c.each {|x| puts x.join(' ')}

