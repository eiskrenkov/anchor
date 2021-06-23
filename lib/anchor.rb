# frozen_string_literal: true

require_relative 'anchor/version'

require_relative 'anchor/configuration'
require_relative 'anchor/thor'
require_relative 'anchor/cli'

module Anchor
  DEPLOYMENT_CONFIGURATION_FILENAME = 'deploy.yml'

  def self.configuration
    @configuration ||= Configuration.new(DEPLOYMENT_CONFIGURATION_FILENAME)
  end
end
