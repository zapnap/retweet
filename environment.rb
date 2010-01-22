require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'dm-aggregates'
require 'haml'
require 'ostruct'
require 'grackle'

require 'sinatra' unless defined?(Sinatra)

configure do
  SiteConfig = OpenStruct.new(
                 :title           => 'Your Twitter App',       # title of application
                 :author          => 'zapnap',                 # your twitter user name for attribution
                 :url_base        => 'http://localhost:4567/', # base URL for your site
                 :search_keywords => ['thundercats', 'snarf'], # search API keyword
                 :status_length   => 20                        # number of tweets to display
               )

  DataMapper.setup(:default, "sqlite3:///#{File.join(File.expand_path(File.dirname(__FILE__)), Sinatra::Base.environment.to_s)}.db")

  # load models
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
  Dir.glob(File.join(File.dirname(__FILE__), 'lib', '*.rb')) { |lib| require File.basename(lib, '.*') }
end

# prevent Object#id warnings
Object.send(:undef_method, :id)
