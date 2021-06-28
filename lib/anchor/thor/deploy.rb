# frozen_string_literal: true

require 'sshkit'
require 'sshkit/dsl'

module Anchor
  module Thor
    module Deploy
      extend Anchor::Thor::Support

      DOCKER_COMPOSE_DOWNLOAD_URL = 'https://github.com/docker/compose/releases/download/'
      DOCKER_COMPOSE_VERSION = '1.29.2'

      REQUIRED_FILES = %w[
        .env
      ]

      commands do
        include SSHKit::DSL

        option :stage, required: true
        option :build, type: :boolean, default: true
        option :push, type: :boolean, default: true
        desc 'deploy [STAGE]', 'Deploy container to the specified stage'
        def deploy
          invoke 'anchor:build' if options[:build]
          invoke 'anchor:push' if options[:push]

          stage = options[:stage]
          stage_configuration = fetch_stage_configuration(stage)

          Anchor::CLI::IO.say("Starting #{stage} deployment!")

          invoke 'anchor:prepare_environment', options: { stage: stage }

          on "#{stage_configuration.user}@#{stage_configuration.host}" do
            root = Anchor.configuration.root

            unless test("[[ -d #{root} ]]")
              Anchor::CLI::IO.say("Root folder doesn't exists! Creating #{root}")
              execute(:mkdir, root)
            end

            within root do
              (Anchor.configuration.required_files + REQUIRED_FILES).each do |filename|
                if test("[[ -f #{root}/#{filename} ]]")
                  Anchor::CLI::IO.say("Found #{filename}", color: :green)
                else
                  Anchor::CLI::IO.say("Couldn't find #{filename} file within #{root}!", color: :red)
                  abort
                end
              end

              docker_compose_filename = stage_configuration.docker.compose.filename

              if test("[[ -f #{root}/#{docker_compose_filename} ]]")
                Anchor::CLI::IO.say("Removing old #{docker_compose_filename}", color: :yellow)
                execute(:rm, docker_compose_filename)
              end

              docker_compose_file_path = Anchor::CLI::Docker::Compose.file_path(docker_compose_filename)

              upload! docker_compose_file_path, root

              docker_compose_base_command = ['docker-compose', '-f', "#{root}/#{docker_compose_filename}"]

              execute(*docker_compose_base_command, 'stop')
              execute(*docker_compose_base_command, 'up', '--detach')

              Anchor::CLI::IO.say("#{stage.capitalize} deployed successfully!", color: :green)
            end
          end
        end

        option :stage, required: true
        desc 'prepare_environment [STAGE]', 'Install required packages before deployment'
        def prepare_environment
          stage = options[:stage]
          stage_configuration = fetch_stage_configuration(stage)

          Anchor::CLI::IO.say("Preparing #{stage} environment...")

          on "#{stage_configuration.user}@#{stage_configuration.host}" do
            if test('docker')
              version = capture('docker --version')
              Anchor::CLI::IO.say("Docker is installed! (#{version})", color: :green)
            else
              Anchor::CLI::IO.say('Docker is not installed in the system, intalling it...')

              execute('curl -fsSL https://get.docker.com -o get-docker.sh')
              execute('sh ./get-docker.sh')
            end

            if test('docker-compose')
              version = capture('docker-compose --version')
              Anchor::CLI::IO.say("Docker compose is installed! (#{version})", color: :green)
            else
              Anchor::CLI::IO.say('Docker compose is not installed in the system, intalling it...')

              kernel_name = capture('uname -s')
              machine_hardware = capture('uname -m')
              docker_compose_build_name = "docker-compose-#{kernel_name}-#{machine_hardware}"

              docker_compose_download_url = [
                DOCKER_COMPOSE_DOWNLOAD_URL,
                DOCKER_COMPOSE_VERSION,
                docker_compose_build_name
              ].join('/')

              execute("sudo curl -L #{docker_compose_download_url} -o /usr/local/bin/docker-compose")
              execute('sudo chmod +x /usr/local/bin/docker-compose')
            end
          end
        end

        no_tasks do
          def fetch_stage_configuration(stage)
            stage_configuration = Anchor.configuration.stages.send(stage)
            return stage_configuration if stage_configuration

            abort "#{stage} environment is not configured in #{Anchor::DEPLOYMENT_CONFIGURATION_FILE}"
          end
        end
      end
    end
  end
end
