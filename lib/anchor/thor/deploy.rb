# frozen_string_literal: true

require 'sshkit'
require 'sshkit/dsl'

module Anchor
  module Thor
    module Deploy
      extend Anchor::Thor::Support

      DOCKER_COMPOSE_DOWNLOAD_URL = 'https://github.com/docker/compose/releases/download/'
      DOCKER_COMPOSE_VERSION = '1.29.2'
      DOCKER_COMPOSE_FILENAME = 'docker-compose.yml'

      commands do
        include SSHKit::DSL

        option :stage, required: true
        option :build, type: :boolean, default: false
        option :push, type: :boolean, default: false
        option :bootstrap, type: :boolean, default: false

        desc 'deploy [STAGE]', 'Deploy container to the specified stage'
        def deploy
          invoke 'anchor:build' if options[:build]
          invoke 'anchor:push' if options[:push]

          stage = options[:stage]
          stage_configuration = fetch_stage_configuration(stage)

          Anchor::CLI::IO.say("Starting #{stage} deployment!")

          invoke 'anchor:bootstrap', options: { stage: stage } if options[:bootstrap]

          on "#{stage_configuration.user}@#{stage_configuration.host}" do
            root = Anchor.configuration.root

            unless test("[[ -d #{root} ]]")
              Anchor::CLI::IO.say("Root folder doesn't exists! Creating #{root}")
              execute(:mkdir, root)
            end

            within root do
              docker_compose_filename = stage_configuration.docker.compose.filename
              docker_compose_file_path = Anchor::CLI::Docker::Compose.file_path(docker_compose_filename)

              upload! docker_compose_file_path, root
              execute('mv', docker_compose_filename, DOCKER_COMPOSE_FILENAME)

              execute('docker-compose', 'stop')

              if !(images_to_pull = stage_configuration.docker.compose.fetch(:pull, [])).empty?
                execute('docker-compose', 'pull', *images_to_pull)
              end

              execute('docker-compose', 'up', '--detach')

              Anchor::CLI::IO.say("#{stage.capitalize} deployed successfully!", color: :green)
            end
          end
        end

        option :stage, required: true

        desc 'restart [STAGE]', 'Restart the container'
        def restart
          stage = options[:stage]
          stage_configuration = fetch_stage_configuration(stage)

          Anchor::CLI::IO.say("Restarting #{stage} container!", color: :red)

          on "#{stage_configuration.user}@#{stage_configuration.host}" do
            within Anchor.configuration.root do
              execute('docker-compose', 'stop')
              execute('docker-compose', 'up', '--detach')
            end
          end

          Anchor::CLI::IO.say("#{stage.capitalize} container restarted!")
        end

        option :stage, required: true

        desc 'bootstrap [STAGE]', 'Install required packages before deployment'
        def bootstrap
          stage = options[:stage]
          stage_configuration = fetch_stage_configuration(stage)

          Anchor::CLI::IO.say("Preparing #{stage} environment...")

          on "#{stage_configuration.user}@#{stage_configuration.host}" do
            root = Anchor.configuration.root

            execute(:mkdir, root) unless test("[[ -d #{root} ]]")

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

            if (bootstrap_configuration = stage_configuration[:bootstrap])
              bootstrap_configuration.fetch(:scp, []).each do |file|
                upload! file, root
              end

              bootstrap_configuration.fetch(:execute, '').split("\n").each do |command|
                execute(command) unless command.empty?
              end
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
