require 'virtus/mapper/version'
require 'virtus'
require 'active_support/core_ext/hash/indifferent_access'

HWIA = ActiveSupport::HashWithIndifferentAccess

module Virtus
  module Mapper

    def initialize(attrs)
      super(map_attributes!(HWIA.new(attrs)))
    end

    private

    def map_attributes!(attrs)
      attrs.tap do |h|
        attributes_to_map_by_symbol(attrs).each do |att|
          h[att.name] = h.delete(from(att))
        end
        attributes_to_map_by_call.each do |att|
          h[att.name] = from(att).call(h)
        end
      end
    end

    def attributes_to_map_by_symbol(attrs)
      attributes_to_map.select do |att|
        !from(att).respond_to?(:call) &&
        !attrs.has_key?(att.name)
      end
    end

    def attributes_to_map_by_call
      attributes_to_map.select { |att| from(att).respond_to?(:call) }
    end

    def attributes_to_map
      attribute_set.select { |att| !(from(att).nil?) }
    end

    def from(attribute)
      attribute.options[:from]
    end
  end
end
