require 'sinatra'
require 'environment'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

error do
  e = request.env['sinatra.error']
  puts e.to_s
  puts e.backtrace.join('\n')
  'Application error'
end

helpers do
  def highlight(text)
    SiteConfig.search_keywords.each do |keyword|
      text = text.gsub(/(#{keyword})/i, '<span class="highlight">\1</span>')
    end
    activate_links(text)
  end

  def activate_links(text)
    text.gsub(/((https?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/, '<a href="\1">\1</a>'). \
      gsub(/@(\w+)/, '<a href="http://twitter.com/\1">@\1</a>')
  end

  def profile_link(user_name)
    "<a href=\"http://twitter.com/#{user_name}\">#{user_name}</a>"
  end
end

# root page
get '/' do 
  @statuses = Status.random(SiteConfig.status_length, 
                            :order => [:created_at.desc], 
                            :limit => SiteConfig.status_length * 3)
  haml :main
end
