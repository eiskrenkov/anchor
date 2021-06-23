# frozen_string_literal: true

require 'sshkit'

module Anchor
  module Thor
    module Docker
      extend Anchor::Thor::Support

      commands do
        desc 'build', 'Build image using Docker compose'
        def build
          Anchor::CLI::Docker::Compose.build
        end

        desc 'push', 'Push image to the container registry'
        def push
          Anchor::CLI::Docker::Compose.push
        end
      end
    end
  end
end
