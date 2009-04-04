require 'rubygems'
require 'couchrest'
require 'haml'
require 'ostruct'
require 'twitter'

require 'sinatra' unless defined?(Sinatra)

configure do
  SiteConfig = OpenStruct.new(
                 :title           => 'Your Twitter App',                     # title of application
                 :author          => 'zapnap',                               # your twitter user name for attribution
                 :url_base        => 'http://localhost:4567/',               # base URL for your site
                 :url_base_db     => 'http://localhost:5984/',               # base URL for CouchDB
                 :db_name         => "retweet-#{Sinatra::Base.environment}", # database name
                 :search_keywords => ['thundercats', 'snarf'],               # search API keyword
                 :status_length   => 20                                      # number of tweets to display
               )

  # load models
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }

  # prevent Object#id warnings
  Object.send(:undef_method, :id)
end

