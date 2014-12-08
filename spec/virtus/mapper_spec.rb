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
          attribute :age, Integer
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

        module Employment
          include Virtus.module
          include Virtus::Mapper

          attribute :company, String, from: :business
          attribute :job_title, String, from: :position
          attribute :salary, Integer
        end

        module Traits
          include Virtus.module
          include Virtus::Mapper

          attribute :eye_color, String, from: :eyecolor
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
    let(:employment_attrs) {
      { salary: 100,  business: 'RentPath', position: 'Programmer' }
    }
    let(:person) { Examples::Person.new(attrs) }

    describe 'attribute with from option as symbol' do
      it 'translates key' do
        expect(person.last_name).to eq(last_name)
      end

      it 'does not create method from original key' do
        expect { person.surname }.to raise_error(NoMethodError)
      end

      describe 'with attribute name as key' do
        it 'does not raise error' do
          expect { Examples::Person.new({ id: 1 }) }.not_to raise_error
        end

        it 'returns expected value' do
          expect(Examples::Person.new({ id: 1 }).id).to eq(1)
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
        expect(person.address).to eq(address)
      end
    end


    describe 'attribute without from option' do
      it 'behaves as usual' do
        expect(person.first_name).to eq(first_name)
      end
    end

    it 'maps attributes with indifferent access' do
      person = Examples::Person.new({ person_id: 1,
                                      first_name: first_name,
                                      'surname' => last_name })
      expect(person.last_name).to eq('Doe')
    end

    describe 'given no arguments to constructor' do
      it 'does not raise error' do
        expect { Examples::Narwhal.new }.not_to raise_error
      end
    end

    describe '#mapped_attributes' do
      let(:person) { Examples::Person.new(attrs.merge({ unused: true })) }

      it 'preserves unused attributes' do
        expect(person.mapped_attributes[:unused]).to be true
      end

      it 'does not create instance methods for unused attributes' do
        expect { person.unused }.to raise_error(NoMethodError)
      end
    end

    describe '#update_attributes!' do
      describe 'for single included module' do
        let(:person) { Examples::Person.new(attrs.merge(employment_attrs)) }

        before do
          person.extend(Examples::Employment)
          person.update_attributes!
        end

        it 'updates unmapped attribute values for extended modules' do
          expect(person.salary).to eq(100)
        end

        it 'updates mapped attribute values for extended modules' do
          expect(person.job_title).to eq('Programmer')
        end
      end

      describe 'for multiple extended modules' do
        let(:person) {
          Examples::Person.new(
            attrs.merge(attrs.merge(employment_attrs).merge({ eyecolor: 'green' }))
          )
        }

        before do
          person.extend(Examples::Employment)
          person.extend(Examples::Traits)
        end

        it 'updates mapped attribute values' do
          pending
          person.update_attributes!
          expect(person.eye_color).to eq('green')
          expect(person.salary).to eq(100)
          expect(person.job_title).to eq('Programmer')
        end

        it 'knows unprocessed attributes' do
          # salary has been processed by Virtus because it is umapped, so
          # person.salary is a legitimate method call, but the value of salary
          # has not been set because we have not run update_attributes! at a time
          # when salary was part of the Virtus's attributes hash
          [:position, :eyecolor, :salary].each do |attr|
            expect(person.attributes_unprocessed).to include(attr)
          end
        end

        it 'knows attributes with nil values' do
          expect(person.attributes_with_nil_values).to include(:eye_color)
        end
      end
    end
  end
end
