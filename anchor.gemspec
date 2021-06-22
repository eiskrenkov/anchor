# frozen_string_literal: true

require_relative 'lib/anchor/version'

Gem::Specification.new do |spec|
  spec.name          = 'anchor'
  spec.version       = Anchor::VERSION

  spec.authors       = ['Egor Iskrenkov']
  spec.email         = ['e.iskrenkov@gmail.com']

  spec.summary       = 'The simplest way to deploy Docker images'
  spec.homepage      = 'https://github.com/eiskrenkov/anchor'

  spec.files         = `git ls-files`.split($RS).reject { |f| f.match(%r{^spec/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = Gem::Requirement.new('~> 3.0.0')

  # Anchor dependencies
  spec.add_dependency 'sshkit', '~> 1.21.2'
  spec.add_development_dependency 'pry', '~> 0.13.1'
end
