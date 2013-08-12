require 'lib/joinable_array'
require 'minitest/autorun'

class JoinableArrayTest < MiniTest::Unit::TestCase
  def typeA(a,b,c,d)
    {:a => a, :b => b, :c => c, :d => d}
  end

  def typeB(a,b,e,f)
    {:a => a, :b => b, :e => e, :f => f}
  end

  def setup
    @a = JoinableArray.new([typeA(4,6,1,2), typeA(7,7,2,2), typeA(8,3,5,5), typeA(9,4,1,7)]) 
    @b = JoinableArray.new([typeB(8,3,1,2), typeB(8,3,2,2), typeB(7,7,5,5), typeB(1,2,3,4)])
  end

  def test_simple_join
    c = @a.
      join_on {|x| [x[:a], x[:b]]}.
      inner_join(@b.join_on {|x| [x[:a], x[:b]]}) {|l,r| l.merge(r)}.
      sort_by {|x| [x[:a], x[:b], x[:c], x[:d], x[:e], x[:f]]}

    assert_equal(3, c.length)
    assert_equal(@a[1].merge(@b[2]), c[0])
    assert_equal(@a[2].merge(@b[0]), c[1])
    assert_equal(@a[2].merge(@b[1]), c[2])
  end

  def test_left_join
    c = @a.
      join_on {|x| [x[:a], x[:b]]}.
      left_join(@b.
        join_on {|x| [x[:a], x[:b]]}.
        fills_with {|key| typeB(key[0], key[1], -1, -2)
      }) {|l,r| l.merge(r)}.
      sort_by {|x| [x[:a], x[:b], x[:c], x[:d], x[:e], x[:f]]}

    assert_equal(5, c.length)
    assert_equal(@a[0].merge({:e => -1, :f => -2}), c[0])
    assert_equal(@a[1].merge(@b[2]), c[1])
    assert_equal(@a[2].merge(@b[0]), c[2])
    assert_equal(@a[2].merge(@b[1]), c[3])
    assert_equal(@a[3].merge({:e => -1, :f => -2}), c[4])
  end

  def test_outer_join
    c = @a.
      join_on {|x| [x[:a], x[:b]]}.
      fills_with {|key| typeA(key[0], key[1], -1, -2)}.
      outer_join(@b.
        join_on {|x| [x[:a], x[:b]]}.
        fills_with {|key| typeB(key[0], key[1], -3, -4)}
      ) {|l,r| l.merge(r)}.
      sort_by {|x| [x[:a], x[:b], x[:c], x[:d], x[:e], x[:f]]}

    assert_equal(6, c.length)
    assert_equal(@b[3].merge({:c => -1, :d => -2}), c[0])
    assert_equal(@a[0].merge({:e => -3, :f => -4}), c[1])
    assert_equal(@a[1].merge(@b[2]), c[2])
    assert_equal(@a[2].merge(@b[0]), c[3])
    assert_equal(@a[2].merge(@b[1]), c[4])
    assert_equal(@a[3].merge({:e => -3, :f => -4}), c[5])
  end

  def test_cross_join
    c = @a.cross_join(@b) {|l,r| l.merge(r)}

    assert_equal(16, c.length)
    d = []
    @a.each do |a|
      @b.each do |b|
        d << a.merge(b)
      end
    end

    c.sort_by! {|x| [x[:a], x[:b], x[:c], x[:d], x[:e], x[:f]]}
    d.sort_by! {|x| [x[:a], x[:b], x[:c], x[:d], x[:e], x[:f]]}

    assert_equal(d, c)
  end

end
