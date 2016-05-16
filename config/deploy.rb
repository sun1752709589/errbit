require 'pry'

# config valid only for Capistrano 3.2.1
lock '3.5.0'

set :application, 'errbit'

set :repo_url, 'https://github.com/sun1752709589/errbit.git'
set :branch, 'master'

set :deploy_to, '/home/deployer/projects/errbit'
set :linked_files, %w{.env config/puma.rb}
#set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/assets}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle}
# set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//, "")
set :rails_env, 'production'
set :rvm_ruby_version, '2.2.2'

namespace :test do
  desc "test"
  task :test_cap do
    on roles(:all), in: :parallel do |host|
      uptime = capture(:uptime)
      puts "#{host.hostname} reports: #{uptime}"
    end
  end
end
# operation and maintenance
namespace :onm do

  desc "Update Repo"
  task :fetch_repo do
    on roles(:all) do |host|
      within repo_path do
        execute "cd #{repo_path};git fetch origin master:master;cd -"
      end
    end
  end

  %w(start stop restart).each do |action|
    desc "#{action} application"
    task action.to_sym do
      invoke "onm:#{action}_rails"
    end
  end

  desc 'Start rails'
  task :start_rails do
    on roles(:app), in: :sequence do
      within release_path do
        execute :bundle, "exec puma --config #{shared_path}/config/puma.rb"
      end
    end
  end

  desc 'Stop rails'
  task :stop_rails do
    on roles(:app), in: :sequence do
      execute :kill, "-INT `cat #{shared_path}/tmp/pids/puma.pid`"
    end
  end

  desc 'Restart rails'
  task :restart_rails do
    on roles(:app), in: :sequence do
      execute :kill, "-USR1 `cat #{shared_path}/tmp/pids/puma.pid`"
    end
  end

  desc 'Start sidekiq'
  task :start_sidekiq do
    on roles(:app), in: :sequence do
      within release_path do
        execute :bundle, "exec sidekiq -d -e production -L #{shared_path}/log/sidekiq.log -p #{shared_path}/tmp/pids/sidekiq.pid -C #{shared_path}/config/sidekiq.yml"
      end
    end
  end

  desc 'Stop sidekiq'
  task :stop_sidekiq do
    on roles(:app), in: :sequence do
      execute :kill, "-INT `cat #{shared_path}/tmp/pids/sidekiq.pid`"
    end
  end

  desc 'Restart sidekiq'
  task :restart_sidekiq do
    on roles(:app), in: :sequence do
      # execute :kill, "-HUP `cat #{shared_path}/tmp/pids/sidekiq.pid`"
      invoke "onm:stop_sidekiq"
      invoke "onm:start_sidekiq"
    end
  end
end

namespace :deploy do
  desc "restart rails"
  after 'deploy:publishing', 'onm:restart_rails'
end

namespace :db do
  desc "Create and setup the mongo db"
  task :setup do
    on roles(:db) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'errbit:bootstrap'
        end
      end
    end
  end
end