require 'lib/joinable_array'
require 'minitest/autorun'

class JoinableArrayTest < MiniTest::Unit::TestCase
  def typeA(a,b,c,d)
    {:a => a, :b => b, :c => c, :d => d}
  end

  def typeB(a,b,e,f)
    {:a => a, :b => b, :e => e, :f => f}
  end

  def test_foo
    a = JoinableArray.new([typeA(4,6,1,2), typeA(7,7,2,2), typeA(8,3,5,5), typeA(9,4,1,7)])
    b = JoinableArray.new([typeB(8,3,1,2), typeB(8,3,2,2), typeB(7,7,5,5), typeB(1,2,3,4)])

    c = a
      .join_on {|x| [x[:a], x[:b]]}
      .left_join(b
        .join_on {|x| [x[:a], x[:b]]}
        .fills_with {|key| typeB(key[0], key[1], 'ee', 'ff')}
      ) {|l,r| l.merge(r)}

    c.each {|x| puts "#{x[:a]} #{x[:b]} #{x[:c]} #{x[:d]} #{x[:e]} #{x[:f]}"}

    c = a
      .join_on {|x| [x[:a], x[:b]]}
      .fills_with {|key| typeA(key[0], key[1], 'cc', 'dd')}
      .outer_join(b
        .join_on {|x| [x[:a], x[:b]]}
        .fills_with {|key| typeB(key[0], key[1], 'ee', 'ff')}
      ) {|l,r| l.merge(r)}

    c.each {|x| puts "#{x[:a]} #{x[:b]} #{x[:c]} #{x[:d]} #{x[:e]} #{x[:f]}"}
  end
end

# puts "first join test"
# c = a.inner_join(b, [:a, :b])
# c.each {|x| puts "#{x[:a]} #{x[:b]} #{x[:c]} #{x[:d]} #{x[:e]} #{x[:f]}"}

# puts "first fill_cube test"
# c = a.fill_cube(b, [:a, :b], {:c => 'cc', :d => 'dd'})
# c.each {|x| puts "#{x[:a]} #{x[:b]} #{x[:c]} #{x[:d]}"}

# puts "second fill_cube test"
# c = b.fill_cube(a, [:a, :b], {:e => 'cc', :f => 'dd'})
# c.each {|x| puts "#{x[:a]} #{x[:b]} #{x[:e]} #{x[:f]}"}

# puts "cross join test"
# c = a.cross_join(b)
# c.each {|x| puts "#{x[:a]} #{x[:b]} #{x[:c]} #{x[:d]} #{x[:e]} #{x[:f]}"}

# puts "left join test"
# c = a.left_join(b, [:a, :b], {:e => 'cc', :f => 'dd'})
# c.each {|x| puts "#{x[:a]} #{x[:b]} #{x[:c]} #{x[:d]} #{x[:e]} #{x[:f]}"}

# puts "right join test"
# c = a.right_join(b, [:a, :b], {:c => 'cc', :d => 'dd'})
# c.each {|x| puts "#{x[:a]} #{x[:b]} #{x[:c]} #{x[:d]} #{x[:e]} #{x[:f]}"}


# puts "examples for JoinableArray"

# typeA = Struct.new(:a, :b, :c, :d)
# typeB = Struct.new(:a, :b, :e, :f)

# a = JoinableArray.new([typeA.new(4,6,1,2), typeA.new(7,7,2,2), typeA.new(8,3,5,5), typeA.new(9,4,1,7)])
# b = JoinableArray.new([typeB.new(8,3,1,2), typeB.new(8,3,2,2), typeB.new(7,7,5,5), typeB.new(1,2,3,4)])

# class JoinedObject
#   def initialize(left, right)
#     @left = left
#     @right = right
#   end
  
#   def method_missing(meth, *args, &block)
#     return @left.send(meth, *args, &block) if @left.respond_to?(meth)
#     return @right.send(meth, *args, &block) if @right.respond_to?(meth)
#     return super(meth, *args, &block)
#   end

#   def respond_to?(meth)
#     @left.respond_to?(meth) || @right.respond_to?(meth)
#   end
# end

# puts "first join test"
# c = a.inner_join(b, [:a, :b]) {|l,r| JoinedObject.new(l,r)}
# c.each {|x| puts "#{x.a} #{x.b} #{x.c} #{x.d} #{x.e} #{x.f}"}

# puts "first fill_cube test"
# c = a.fill_cube(b, [:a, :b]) {|a,b| typeA.new(a, b, 'cc', 'dd')}
# c.each {|x| puts "#{x.a} #{x.b} #{x.c} #{x.d}"}

# puts "second fill_cube test"
# c = b.fill_cube(a, {:e => :c, :f => :d}) {|e,f| typeB.new('aa', 'bb', e, f)}
# c.each {|x| puts "#{x.a} #{x.b} #{x.e} #{x.f}"}

# puts "cross join test"
# c = a.cross_join(b) {|l,r| JoinedObject.new(l,r)}
# c.each {|x| puts "#{x.a} #{x.b} #{x.c} #{x.d} #{x.e} #{x.f}"}

# puts "examples for JoinableArrayOfArrays"

# a = JoinableArrayOfArrays.new([[4,6,1,2], [7,7,2,2], [8,3,5,5], [9,4,1,7]])
# b = JoinableArrayOfArrays.new([[8,3,1,2], [8,3,2,2], [7,7,5,5], [1,2,3,4]])

# puts "first join test"
# c = a.inner_join(b, [0, 1])
# c.each {|x| puts x.join(' ')}

# puts "first fill_cube test"
# c = a.fill_cube(b, [0, 1], [0,1,'aa','bb'])
# c.each {|x| puts x.join(' ')}

# puts "second fill_cube test"
# c = b.fill_cube(a, [0, 1], [0,1,'cc','dd'])
# c.each {|x| puts x.join(' ')}

# puts "cross join test"
# c = a.cross_join(b)
# c.each {|x| puts x.join(' ')}

# puts "left join test"
# c = a.left_join(b, [0, 1], [0, 1, 'ee', 'ff'])
# c.each {|x| puts x.join(' ')}

# puts "right join test"
# c = a.right_join(b, [0, 1], [0, 1, 'cc', 'dd'])
# c.each {|x| puts x.join(' ')}

