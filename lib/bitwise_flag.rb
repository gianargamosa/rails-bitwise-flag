# frozen_string_literal: true

require_relative "bitwise_flag/version"

module BitwiseFlag
  class Error < StandardError; end
  # Your code goes here...
  class_methods do
    def flags(column, keys)
      # Store all defined flags
      unless respond_to?(:defined_flags)
        class_attribute :defined_flags
        self.defined_flags = {}
      end

      raise "defined_flags on :#{column} already defined!" if defined_flags[column]

      self.defined_flags[column] = Hash[keys.map.with_index{|key, bit| [key, 2**bit] }].freeze

      # Define model method to display all flags on column
      define_singleton_method column.to_s.sub('_flag', '').pluralize do
        self.defined_flags[column]
      end

      # Define method to display all selected flags on column
      define_method column.to_s.sub('_flag', '').pluralize do
        self.defined_flags[column].map{|key, value| key if (read_attribute(column) & value) != 0 }.compact
      end

      keys.each_with_index do |key, bit|
        # Getters
        define_method key do
          (read_attribute(column) & 2**bit) == 2**bit
        end
        alias_method "#{key}?", key

        # Setters
        define_method "#{key}=" do |should_set|
          value = should_set ? read_attribute(column) | (1 << bit) : read_attribute(column) & ~(1 << bit)
          write_attribute(column, value)
        end
      end
    end
  end
end
