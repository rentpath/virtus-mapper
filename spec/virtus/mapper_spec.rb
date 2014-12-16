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

        class Dog
          include Virtus.model
          include Virtus::Mapper

          attribute :name, String, from: :shelter
        end
      end
    end

    let(:person_id) { 1 }
    let(:first_name) { 'John' }
    let(:last_name) { 'Doe' }
    let(:address) { '1122 Something Avenue' }
    let(:person_attrs) {
      { person_id: person_id,
        first_name: first_name,
        surname: last_name,
        address: { 'street' => address } }
    }
    let(:employment_attrs) {
      { salary: 100,  business: 'RentPath', position: 'Programmer' }
    }
    let(:person) { Examples::Person.new(person_attrs) }

    describe 'attribute with from option as symbol' do
      it 'translates key' do
        expect(person.last_name).to eq(last_name)
      end

      it 'does not create method from original key' do
        expect { person.surname }.to raise_error(NoMethodError)
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
        expect(callable).to receive(:call) { person_attrs }
        Examples::Person.new(person_attrs)
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
        expect { Examples::Dog.new }.not_to raise_error
      end
    end

    describe '#mapped_attributes' do
      let(:person) { Examples::Person.new(person_attrs.merge({ unused: true })) }

      it 'preserves unused attributes' do
        expect(person.mapped_attributes[:unused]).to be true
      end

      it 'does not create instance methods for unused attributes' do
        expect { person.unused }.to raise_error(NoMethodError)
      end
    end

    describe '#extend_with' do
      describe 'for single extended module' do
        let(:person) {
          Examples::Person.new(person_attrs.merge(employment_attrs))
        }

        before do
          person.extend_with(Examples::Employment)
        end

        it 'updates unmapped attribute values for extended modules' do
          expect(person.salary).to eq(100)
        end

        it 'updates mapped attribute values for extended modules' do
          expect(person.job_title).to eq('Programmer')
        end

        it 'adds module attributes to attribute_set' do
          attr_names = person.instance_eval { attribute_set }.collect(&:name)
          [:id,
           :first_name,
           :last_name,
           :address,
           :company,
           :job_title,
           :salary].each do |attr_name|
             expect(attr_names).to include(attr_name)
           end
        end
      end

      describe 'for multiple extended modules' do
        let(:person) {
          Examples::Person.new(
            person_attrs.merge(employment_attrs.merge({ eyecolor: 'green' }))
          )
        }

        before do
          person.extend_with(Examples::Employment)
          person.extend_with(Examples::Traits)
        end

        it 'updates mapped attributes for last module extended' do
          expect(person.eye_color).to eq('green')
        end

        it 'updates mapped attributes for first module extended' do
          expect(person.salary).to eq(100)
          expect(person.company).to eq('RentPath')
          expect(person.job_title).to eq('Programmer')
        end

        it 'adds module attributes to attribute_set' do
          attr_names = person.instance_eval { attribute_set }.collect(&:name)
          [:id,
           :first_name,
           :last_name,
           :address,
           :company,
           :job_title,
           :salary,
           :eye_color].each do |attr_name|
             expect(attr_names).to include(attr_name)
           end
        end
      end
    end
  end
end
