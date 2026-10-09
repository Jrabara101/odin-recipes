# frozen_string_literal: true

module Enumerable
  def my_each_with_index
    return to_enum(:my_each_with_index) unless block_given?

    index = 0
    my_each do |element|
      yield element, index
      index += 1
    end
    self
  end

  def my_select
    return to_enum(:my_select) unless block_given?

    selected = []
    my_each do |element|
      selected << element if yield(element)
    end
    selected
  end

  def my_all?
    if block_given?
      my_each { |element| return false unless yield(element) }
    else
      my_each { |element| return false unless element }
    end
    true
  end

  def my_any?
    if block_given?
      my_each { |element| return true if yield(element) }
    else
      my_each { |element| return true if element }
    end
    false
  end

  def my_none?
    if block_given?
      my_each { |element| return false if yield(element) }
    else
      my_each { |element| return false if element }
    end
    true
  end

  def my_count(*args)
    count = 0
    if block_given?
      my_each { |element| count += 1 if yield(element) }
    elsif args.length == 1
      target = args.first
      my_each { |element| count += 1 if element == target }
    else
      my_each { count += 1 }
    end
    count
  end

  def my_map(proc = nil)
    return to_enum(:my_map) unless block_given? || proc

    result = []
    my_each do |element|
      result << (proc ? proc.call(element) : yield(element))
    end
    result
  end

  def my_inject(*args)
    if block_given?
      if args.empty?
        initial_set = false
        accumulator = nil
        my_each do |element|
          if initial_set
            accumulator = yield(accumulator, element)
          else
            accumulator = element
            initial_set = true
          end
        end
      else
        accumulator = args.first
        my_each do |element|
          accumulator = yield(accumulator, element)
        end
      end
      accumulator
    elsif args.first.is_a?(Symbol) || (args.length == 2 && args[1].is_a?(Symbol))
      if args.length == 2
        accumulator = args[0]
        symbol = args[1]
        my_each { |element| accumulator = accumulator.send(symbol, element) }
      else
        symbol = args[0]
        initial_set = false
        accumulator = nil
        my_each do |element|
          if initial_set
            accumulator = accumulator.send(symbol, element)
          else
            accumulator = element
            initial_set = true
          end
        end
      end
      accumulator
    end
  end
end

# You will first have to define my_each
# on the Array class. Methods defined in
# your enumerable module will have access
# to this method
class Array
  def my_each
    return to_enum(:my_each) unless block_given?

    i = 0
    while i < size
      yield self[i]
      i += 1
    end
    self
  end
end
