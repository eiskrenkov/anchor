# require './lib/rake/support'

require 'sshkit'
require 'sshkit/dsl'

desc 'Deploy'
task :deploy do
  include SSHKit::DSL

  puts("Starting the deployment!")

  on 'root@minecraft.iskrenkov.com' do
    puts capture('ls -l')
  end
end
