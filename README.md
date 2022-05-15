# Anchor - Simple containers deployment tool
It builds your image using docker-compose, pushes it to the registry of your choise, pulls it onto remote machine and runs `docker-compose up`, it's as simple as that!

## Installation
Install anchor on your machine as any other Ruby gem

```sh
gem install anchor --source "https://rubygems.pkg.github.com/eiskrenkov"
```

## Usage

Place `deploy.yml` in your project's directory

```yaml
root: /path/to/project
required_files:
  - foo.bar

stages:
  production:
    user: root
    host: host.example.com
    docker:
      compose:
        filename: docker-compose-production.yml

```

Run `anchor deploy --stage production [--no-build] [--no-push]`
