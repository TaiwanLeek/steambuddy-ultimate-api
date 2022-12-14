# frozen_string_literal: true

require 'rake/testtask'
require_relative 'require_app'

CODE = 'lib/'
APP_PORT = '9000'
API_PORT = '9090'

task :default do
  puts `rake -T`
end

desc 'Run unit and integration tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/tests/**/*_spec.rb'
  t.warning = false
end

desc 'Keep rerunning unit/integration tests upon changes'
task :respec do
  sh "rerun -c 'rake spec' --ignore 'coverage/*' --ignore 'repostore/*'"
end

desc 'Run the webserver and application and restart if code changes'
task :rerun do
  sh "rerun -c --ignore 'coverage/*' --ignore 'repostore/*' -- bundle exec puma"
end

desc 'Run service'
task :run do
  sh "bundle exec puma -p #{API_PORT}"
end

namespace :run do
  desc 'Run API in dev mode'
  task :dev do
    sh "bundle exec puma -p #{API_PORT}"
  end

  desc 'Run API in test mode'
  task :test do
    sh "RACK_ENV=test bundle exec puma -p #{API_PORT}"
  end
end

desc 'Run application console'
task :console do
  sh 'pry -r ./load_all'
end

desc 'Generates a 64 by secret for Rack::Session'
task :new_session_secret do
  require 'base64'
  require 'securerandom'
  secret = SecureRandom.random_bytes(64).then { Base64.urlsafe_encode64(_1) }
  puts "SESSION_SECRET: #{secret}"
end

namespace :db do
  task :config do
    require 'sequel'
    require_relative 'config/environment' # load config info

    def app = SteamBuddy::App
  end

  desc 'Run migrations'
  task migrate: :config do
    Sequel.extension :migration
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.DB, 'db/migrations')
  end

  desc 'Delete dev or test database file (set correct RACK_ENV)'
  task drop: :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    FileUtils.rm(SteamBuddy::App.config.DB_FILENAME)
    puts "Deleted #{SteamBuddy::App.config.DB_FILENAME}"
  end
end

namespace :vcr do
  desc 'delete cassette fixtures'
  task :wipe do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end
end

namespace :quality do
  desc 'run all static-analysis quality checks'
  task all: %i[rubocop reek flog]

  desc 'code style linter'
  task :rubocop do
    sh 'rubocop'
  end

  desc 'code smell detector'
  task :reek do
    sh 'reek'
  end

  desc 'complexiy analysis'
  task :flog do
    sh "flog #{CODE}"
  end
end

namespace :worker do
  namespace :fetch_run do
    desc 'Run the background cloning worker in development mode'
    task dev: :config do
      sh 'RACK_ENV=development bundle exec shoryuken -r ./workers/fetch_player_worker.rb -C ./workers/fetch_player/shoryuken_dev.yml'
    end

    desc 'Run the background cloning worker in testing mode'
    task test: :config do
      sh 'RACK_ENV=test bundle exec shoryuken -r ./workers/fetch_player_worker.rb -C ./workers/fetch_player/shoryuken_test.yml'
    end

    desc 'Run the background cloning worker in production mode'
    task production: :config do
      sh 'RACK_ENV=production bundle exec shoryuken -r ./workers/fetch_player_worker.rb -C ./workers/fetch_player/shoryuken.yml'
    end
  end

  namespace :update_run do
    desc 'Run the background cloning worker in development mode'
    task dev: :config do
      sh 'RACK_ENV=development bundle exec shoryuken -r ./workers/update_player_worker.rb -C ./workers/update_player/shoryuken_dev.yml'
    end

    desc 'Run the background cloning worker in testing mode'
    task test: :config do
      sh 'RACK_ENV=test bundle exec shoryuken -r ./workers/update_player_worker.rb -C ./workers/update_player/shoryuken_test.yml'
    end

    desc 'Run the background cloning worker in production mode'
    task production: :config do
      sh 'RACK_ENV=production bundle exec shoryuken -r ./workers/update_player_worker.rb -C ./workers/update_player/shoryuken.yml'
    end
  end
end
