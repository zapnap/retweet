require 'application'

set :run, false
set :environment, :production

FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new(File.join('log', 'sinatra.log'), 'a')
$stdout.reopen(log)
$stderr.reopen(log)

run Sinatra::Application
