#
# frozen_string_literal: true
module Loofah

  #
  #  A RuntimeError raised when Loofah could not find an appropriate constant name in SafeList.
  #
  class AllowedConstantNotFound < RuntimeError; end

  module HTML5
    module SafeList
      module RedefinableConstants
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          # constant_name is one of constant names from SafeList
          def redefine_allowed_safelist_constant(constant_name, values)
            constantized_name = constant_name.to_s.upcase
            values_set = Set.new(values)

            unless const_defined?(constantized_name)
              raise AllowedConstantNotFound, "No constant with #{constantized_name} name has been defined in SafeList"
            end

            remove_const(constantized_name)

            self.const_set(constantized_name, values_set)
          end
        end
      end
    end
  end
end
