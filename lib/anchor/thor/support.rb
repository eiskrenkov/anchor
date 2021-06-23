# frozen_string_literal: true

module Anchor
  module Thor
    module Support
      def self.extended(base)
        base.define_singleton_method(:included) do |thor|
          thor.class_eval(&@_commands_block)
        end
      end

      def commands(&commands_definition)
        @_commands_block = commands_definition
      end
    end
  end
end
