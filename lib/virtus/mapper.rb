require 'virtus/mapper/version'
require 'virtus'
require 'active_support/core_ext/hash/indifferent_access'

HWIA = ActiveSupport::HashWithIndifferentAccess

module Virtus
  module Mapper

    attr_reader :raw_attributes, :nil_value_keys
    attr_accessor :attr_set

    def initialize(attrs={})
      @attr_set = init_attr_set
      @raw_attributes = HWIA.new(attrs)
      @nil_value_keys = @raw_attributes.collect { |k, v| k if v.nil? }.compact
      super(mapped_attributes)
    end

    def add_attributes(mod)
      mod_attrs = module_attributes(mod)
      attr_set.merge(mod_attrs)
      mapped_attrs = mapped_attributes
      mod_attrs.each do |attr|
        value = attr.coerce(mapped_attrs[attr.name])
        define_singleton_method(attr.name) { value }
      end
    end

    private

    def init_attr_set
      Virtus::AttributeSet.new(nil, class_attributes)
    end

    def class_attributes
      self.class.attribute_set.to_a
    end

    def module_attributes(mod)
      Class.new { include mod }.attribute_set.to_a
    end

    def mapped_attributes
      attrs = raw_attributes.clone
      attrs.tap do |h|
        attributes_to_map_by_symbol(attrs).each do |att|
          h[att.name] = h.delete(from(att))
        end
        attributes_to_map_by_call.each do |att|
          h[att.name] = from(att).call(h)
        end
      end.delete_if { |k, v| delete_nil_value_for?(k, v) }
    end

    def delete_nil_value_for?(k, v)
      !nil_value_keys.include?(k) && v.nil?
    end

    def attributes_to_map_by_symbol(attrs)
      attributes_to_map - attributes_to_map_by_call
    end

    def attributes_to_map_by_call
      attributes_to_map.select { |att| from(att).respond_to?(:call) }
    end

    def attributes_to_map
      attr_set.select { |att| !(from(att).nil?) }
    end

    def from(attribute)
      attribute.options[:from]
    end
  end
end
