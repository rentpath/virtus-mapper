require 'virtus/mapper/version'
require 'virtus'
require 'active_support/core_ext/hash/indifferent_access'

HWIA = ActiveSupport::HashWithIndifferentAccess

module Virtus
  module Mapper

    def initialize(attrs)
      super(map_attributes!(attrs))
    end

    def map_attributes!(attrs)
      HWIA.new(attrs).tap do |h|
        mapped_attributes.each do |attr|
          from = attr.options[:from]
          h[attr.name] = from.respond_to?(:call) ? from.call(h) : h.delete(from)
        end
      end
    end

    def mapped_attributes
      attribute_set.select { |att| att.options[:from] }
    end

  end
end
