# frozen_string_literal: true

require_relative 'anchor/version'

require_relative 'anchor/thor'
require_relative 'anchor/cli'

require 'open_config'

module Anchor
  DEPLOYMENT_CONFIGURATION_FILE = 'deploy.yml'

  def self.configuration
    @configuration ||= OpenConfig::YAML.new(DEPLOYMENT_CONFIGURATION_FILE)
  end
end
