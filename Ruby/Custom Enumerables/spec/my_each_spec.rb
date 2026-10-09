# frozen_string_literal: true

require_relative '../lib/my_enumerables'

RSpec.describe Array do
  subject(:array) { [1, 1, 2, 3, 5, 8, 13, 21, 34] }

  describe '#my_each' do
    context 'when given a block' do
      it 'returns the original array' do
        my_each_results = array.my_each do |_element|
          # This should return the original array
          # no matter the contents of the block
        end

        expect(my_each_results).to eq(array)
      end

      it 'executes the block for each element' do
        my_each_results = []
        each_results = []

        array.my_each do |element|
          my_each_results << element * 2
        end

        array.each do |element|
          each_results << element * 2
        end

        expect(my_each_results).to eq(each_results)
      end
    end

    context 'when not given a block' do
      it 'returns an Enumerator' do
        expect(array.my_each).to be_a Enumerator
      end

      it 'contains the elements of the receiving array' do
        expect(array.my_each.to_a).to eq array
      end
    end
  end
end
