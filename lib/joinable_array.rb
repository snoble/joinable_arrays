class RelationalMethods
  def self.inner_join(left_a, right_a, left_key, right_key, &block)
    left, right = left_and_right(left_a, right_a, left_key, right_key)
    join(left, right, left_a, &block)
  end

  def self.left_join(left_a, right_a, left_key, right_key, fill, &block)
    left, right = left_and_right(left_a, right_a, left_key, right_key)
    right = fill_cube(right, left, &fill).sort_by {|x| x[:key]}
    join(left, right, left_a, &block)
  end

  def self.right_join(left_a, right_a, left_key, right_key, fill, &block)
    left, right = left_and_right(left_a, right_a, left_key, right_key)
    left = fill_cube(left, right, &fill).sort_by {|x| x[:key]}
    join(left, right, left_a, &block)
  end

  def self.outer_join(left_a, right_a, left_key, right_key, left_fill, right_fill, &block)
    left, right = left_and_right(left_a, right_a, left_key, right_key)
    left = fill_cube(left, right, &left_fill).sort_by {|x| x[:key]}
    right = fill_cube(right, left, &right_fill).sort_by {|x| x[:key]}
    join(left, right, left_a, &block)
  end

  def self.fill_cube(left, right, &block)
    right_hash = right[idx = 0]
    new_array = left.slice(0, left.size)
    previously_added = nil
    left.each do |left_hash|
      while right_hash && (right_hash[:key] <=> left_hash[:key]) < 0
        if previously_added == nil || (right_hash[:key] <=> previously_added) > 0
          previously_added = right_hash[:key] 
          new_array << {key: right_hash[:key], object: block ? block.call(right_hash[:key]) : nil}
        end
        right_hash = right[idx += 1]
      end
      while right_hash && right_hash[:key] == left_hash[:key]
        right_hash = right[idx += 1]
      end
    end
    while right_hash
      if previously_added == nil || (right_hash[:key] <=> previously_added) > 0
        previously_added = right_hash[:key]
        new_array << {key: right_hash[:key], object: block ? block.call(right_hash[:key]) : nil}
      end
      right_hash = right[idx += 1]
    end
    new_array
  end

  def self.join(left, right, prototype_container)
    anchor = 0
    new_array = prototype_container.slice(0,0)
    left.each do |left_hash|
      right_hash = right[anchor]
      while right_hash && (right_hash[:key] <=> left_hash[:key]) < 0
        right_hash = right[anchor += 1]
      end
      idx = anchor
      while right_hash && right_hash[:key] == left_hash[:key]
        new_array << yield(left_hash[:object], right_hash[:object])
        right_hash = right[idx += 1]
      end
    end
    new_array
  end

  def self.left_and_right(left_a, right_a, left_key, right_key)
    left = left_a.map {|x| {:key => left_key ? left_key.call(x) : 0, :object => x}}
      .sort_by {|x| x[:key]}
    right = right_a.map {|x| {:key => right_key ? right_key.call(x) : 0, :object => x}}
      .sort_by {|x| x[:key]}
    [left, right]
  end
end

module Joinable
  def inner_join(that, &block)
    RelationalMethods.inner_join(self, that, join_key, that.join_key, &block)
  end

  def join_on(&block)
    @join_key = block
    self
  end

  def join_key
    @join_key
  end

  def fills_with(&block)
    @fill_row = block
    self
  end

  def fill_row
    @fill_row
  end

  def cross_join(that, &block)
    RelationalMethods.inner_join(self, that, nil, nil, &block)
  end

  def left_join(that, &block)
    RelationalMethods.left_join(self, that, join_key, that.join_key, that.fill_row, &block)
  end

  def right_join(that, &block)
    RelationalMethods.right_join(self, that, join_key, that.join_key, fill_row, &block)
  end

  def outer_join(that, &block)
    RelationalMethods.outer_join(self, that, join_key, that.join_key, fill_row, that.fill_row, &block)
  end
end

class JoinableArray < Array
  include Joinable
end

