# frozen_string_literal: true

require_relative 'cli/io'
require_relative 'cli/docker'

module Anchor
  module CLI
    class << self
      def exec(command, *options, status_code: false)
        full_command = "#{command} #{options.join(' ')}"

        Anchor::CLI::IO.say('[CLI] Executing ', color: :pink, newline: false)
        Anchor::CLI::IO.say(full_command, color: :blue)

        status_code ? system(full_command) : `#{full_command}`.strip
      end
    end
  end
end
