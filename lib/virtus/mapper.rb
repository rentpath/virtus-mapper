require 'virtus/mapper/version'
require 'virtus'
require 'active_support/core_ext/hash/indifferent_access'

HWIA = ActiveSupport::HashWithIndifferentAccess

module Virtus
  module Mapper

    attr_reader :mapped_attributes

    def initialize(attrs={})
      @mapped_attributes = HWIA.new(attrs)
      super(map_attributes!(@mapped_attributes))
    end

    def update_attributes
      map_attributes!(mapped_attributes)
      attrs_to_update = (attributes_unprocessed + attributes_with_nil_values).compact.uniq
      attrs_to_update.each do |name|
        self.send("#{name}=", mapped_attributes[name])
      end
    end

    def attributes_unprocessed
      # NOTE: https://github.com/solnic/virtus/issues/266 may affect this
      # Workaround to the bug would be to go through mapped_attributes and capture
      # keys that throw NoMethodError on send
      # Any attributes (keys) in mapped_attributes that Virtus has not processed and
      # is not aware of - unprocessed_attributes

      mapped_attributes.keys.collect do |key|
        begin
          self.send(key)
          if self.send(key).nil?
            key.to_sym
          end
        rescue NoMethodError
          key.to_sym
        end
      end
    end

    def attributes_with_nil_values
      attributes.map { |k,v| k if v.nil? }
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
