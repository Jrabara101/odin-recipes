# frozen_string_literal: true

require_relative '../lib/my_enumerables'

RSpec.describe Enumerable do
  subject(:enumerable) { [1, 1, 2, 3, 5, 8, 13, 21, 34] }

  describe '#my_each_with_index' do
    context 'when given a block' do
      it 'returns the original enumerable' do
        my_each_with_index_results = enumerable.my_each_with_index do |_element|
          # This should return the original enumerable
          # no matter the contents of the block
        end

        expect(my_each_with_index_results).to eq(enumerable)
      end

      it 'executes the block for each element and index' do
        my_each_with_index_results = []
        each_with_index_results = []

        enumerable.my_each_with_index do |element, index|
          my_each_with_index_results << [element * 2, index * 2]
        end

        enumerable.each_with_index do |element, index|
          each_with_index_results << [element * 2, index * 2]
        end

        expect(my_each_with_index_results).to eq(each_with_index_results)
      end
    end

    context 'when not given a block' do
      it 'returns an Enumerator' do
        expect(enumerable.my_each_with_index).to be_a Enumerator
      end

      it 'contains the elements and indices of the receiving array' do
        expect(enumerable.my_each_with_index.to_a).to eq(
          [[1, 0], [1, 1], [2, 2],
          [3, 3], [5, 4], [8, 5],
          [13, 6], [21, 7], [34, 8]]
        )
      end
    end
  end
end
