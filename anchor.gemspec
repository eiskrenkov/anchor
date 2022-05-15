# frozen_string_literal: true

require_relative 'lib/anchor/version'

Gem::Specification.new do |spec|
  spec.name          = 'anchor'
  spec.version       = Anchor::VERSION

  spec.authors       = ['Egor Iskrenkov']
  spec.email         = ['e.iskrenkov@gmail.com']

  spec.summary       = 'The simplest way to deploy Docker images'
  spec.homepage      = 'https://github.com/eiskrenkov/anchor'

  spec.files         = Dir['lib/**/*.rb']
  spec.bindir        = 'bin'
  spec.executables   = spec.name
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4'

  # Anchor dependencies
  spec.add_dependency 'open_config', '~> 2.0'
  spec.add_dependency 'sshkit', '~> 1.21.2'
  spec.add_dependency 'thor', '~> 1.1.0'
end
