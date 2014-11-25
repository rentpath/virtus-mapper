require 'virtus'
require 'virtus/mapper'

module Virtus
  RSpec.describe Mapper do

    before do
      module Examples
        class Person
          include Virtus.model
          include Virtus::Mapper

          attribute :id, Integer, from: :person_id, strict: true, required: true
          attribute :first_name, String
          attribute :last_name, String, from: :surname
          attribute :address,
                    String,
                    default: '',
                    from: lambda { |atts| atts[:address][:street] rescue '' }
        end

        class Narwhal
          include Virtus.model
          include Virtus::Mapper

          attribute :name, String, from: :narwhalmom
        end
      end
    end

    let(:person_id) { 1 }
    let(:first_name) { 'John' }
    let(:last_name) { 'Doe' }
    let(:address) { '1122 Something Avenue' }
    let(:attrs) {
      { person_id: person_id,
        first_name: first_name,
        surname: last_name,
        address: { 'street' => address } }
    }
    let(:mapper) { Examples::Person.new(attrs) }

    describe 'attribute with from option as symbol' do
      it 'translates key' do
        expect(mapper.last_name).to eq(last_name)
      end

      it 'does not create method from original key' do
        expect { mapper.surname }.to raise_error(NoMethodError)
      end

      describe 'with attribute name as key' do
        it 'does not raise error' do
          expect { Examples::Person.new({id: 1}) }.not_to raise_error
        end

        it 'returns expected value' do
          expect(Examples::Person.new({id: 1}).id).to eq(1)
        end
      end
    end

    describe 'attribute with from option as callable object' do
      it 'calls the object and passes the attributes hash' do
        callable = Examples::Person.attribute_set[:address].options[:from]
        expect(callable).to receive(:call) { attrs }
        Examples::Person.new(attrs)
      end

      it 'sets attribute to result of call' do
        expect(mapper.address).to eq(address)
      end
    end


    describe 'attribute without from option' do
      it 'behaves as usual' do
        expect(mapper.first_name).to eq(first_name)
      end
    end

    it 'maps attributes with indifferent access' do
      mapper = Examples::Person.new({ person_id: 1,
                                      first_name: first_name,
                                      'surname' => last_name })
      expect(mapper.last_name).to eq('Doe')
    end

    describe 'given no arguments to constructor' do
      it 'does not raise error' do
        expect {
          Examples::Narwhal.new
        }.not_to raise_error
      end
    end
  end
end
