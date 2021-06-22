# frozen_string_literal: true

require_relative 'anchor/version'

module Anchor
  module CLI
    autoload :IO, './lib/anchor/cli/io'
    autoload :Docker, './lib/anchor/cli/docker'
  end
end
