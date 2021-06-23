# frozen_string_literal: true

require 'thor'

require_relative 'thor/support'
require_relative 'thor/deploy'
require_relative 'thor/docker'

module Anchor
  module Thor
    class CLI < ::Thor
      namespace :anchor

      include Anchor::Thor::Deploy
      include Anchor::Thor::Docker

      no_commands do
        def invoke(task, args: [], options: {})
          super(task, args, options)
        end
      end
    end
  end
end
