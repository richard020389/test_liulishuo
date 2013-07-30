require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'mina/rvm'    # for rvm support. (http://rvm.io)
require 'rbconfig'
require 'mina/whenever'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)
#set :user, 'root'
#set :user, 'www-data'
#set :domain, '42.120.16.119'
set :domain, 'railsu@42.120.16.119'
set :deploy_to, '/home/railsu/test_liulishuo_release'
set :repository, 'git@github.com:richard020389/test_liulishuo.git'
set :branch, 'master'
set :app_path, "#{deploy_to}/current"
#set :term_mode, :exec  if Process.respond_to?(:fork)
set :term_mode, :exec  if RbConfig::CONFIG['host_os'] =~/mswin|mingw/


# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'log']

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use[ruby-2.0.0-p195@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  #queue  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]
  queue! %[cp /home/railsu/tuuzi/config/database.yml "#{deploy_to}/shared/config/database.yml"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/pids"]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate:force'
    invoke :'rails:assets_precompile:force'

    queue 'echo $build_path'
    queue 'echo $release_path'
    queue 'pwd'
    #$ mv "$build_path" "$release_path"
    to :launch do
      #queue 'touch tmp/restart.txt'
      invoke :'unicorn:restart'
      invoke :'whenever:update'
    end
  end
end
#                                                                       Unicorn
# ==============================================================================
namespace :unicorn do
    set :unicorn_pid, "#{app_path}/tmp/pids/unicorn.pid"
    set :start_unicorn, %[
      cd #{app_path}
      unicorn_rails -c #{app_path}/config/unicorn.rb -E production -D
    ]
 
#                                                                    Start task
# ------------------------------------------------------------------------------
  desc "Start unicorn"
  task :start => :environment do
    queue 'echo "-----> Start Unicorn"'
    #queue! start_unicorn
    queue! "cd #{app_path}"
    queue! "bundle exec unicorn_rails -c #{app_path}/config/unicorn.rb -E production -D"
  end
 
#                                                                     Stop task
# ------------------------------------------------------------------------------
  desc "Stop unicorn"
  task :stop do
    queue 'echo "-----> Stop Unicorn"'
    queue! %[
      echo `cat #{unicorn_pid}`
      test -s "#{unicorn_pid}" && kill -QUIT `cat "#{unicorn_pid}"` && echo "Stop Ok"
      echo >&2 "Not running"
    ]
    #queue! %[
    #  test -s #{unicorn_pid} && echo "start" && kill -QUIT #{pid} && echo "Stop Ok" && exit 0
    #  echo >&2 "Not running"
    #]
  end
 
#                                                                  Restart task
# ------------------------------------------------------------------------------
  desc "Restart unicorn using 'upgrade'"
  task :restart => :environment do
    invoke 'unicorn:stop'
    sleep 1
    invoke 'unicorn:start'
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers


