workers 2
threads 0, 16
bind 'tcp://0.0.0.0:10004'
environment 'production'
daemonize true

directory '/home/deployer/projects/errbit/current'
rackup '/home/deployer/projects/errbit/current/config.ru'
pidfile '/home/deployer/projects/errbit/shared/tmp/pids/puma.pid'
stdout_redirect '/home/deployer/projects/errbit/shared/log/puma.stdout.log', '/home/deployer/projects/errbit/shared/log/puma.stderr.log', true
state_path '/home/deployer/projects/errbit/shared/tmp/sockets/puma.state'

on_restart do
  puts 'On restart...'
end

on_worker_boot do
  puts 'On worker boot...'
end

after_worker_boot do
  puts 'On worker boot...'
end

prune_bundler