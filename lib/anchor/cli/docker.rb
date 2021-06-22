# frozen_string_literal: true

module CLI::Docker
  TAG = :latest

  class << self
    # Building Docker Image using passed Dockerfile and tagging it with target host
    #
    # > docker build -t ghcr.io/OWNER/IMAGE_NAME:latest .
    #
    def build(dockerfile, options = {})
      command = ['build', '-t', image, '-f', dockerfile]

      unless options.empty?
        args = options.map do |key, value|
          "#{key}=#{value}"
        end

        command.concat(['--build-arg', *args])
      end

      docker(*command, '.', status_code: true)
    end

    # Pushing image to the GitHub Package Registry
    #
    # > docker push ghcr.io/OWNER/IMAGE_NAME:latest
    #
    def push
      docker('push', "#{image}:#{TAG}")
    end

    # Composed image name (ghcr.io/OWNER/IMAGE_NAME)
    def image
      @image ||= "#{configuration.image.host}/#{configuration.image.owner}/#{configuration.image.name}"
    end

    private

    def configuration
      @configuration ||= Configuration.docker
    end

    def docker(*command, status_code: false)
      CLI.exec(:docker, *command, status_code: status_code)
    end
  end
end
