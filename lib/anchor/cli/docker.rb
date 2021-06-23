# frozen_string_literal: true

module Anchor
  module CLI
    module Docker
      module Compose
        class FileNotFound < StandardError
          def initialize
            super("Can't find Docker compose file")
          end
        end

        class << self
          def build
            docker_compose(:build)
          end

          def push
            docker_compose(:push)
          end

          def file_path(filename)
            File.join(Dir.pwd, filename).tap do |path|
              raise FileNotFound unless File.exists?(path)
            end
          end

          private

          def docker_compose(*command, status_code: true)
            Anchor::CLI.exec('docker-compose', *command, status_code: status_code)
          end
        end
      end
    end
  end
end
