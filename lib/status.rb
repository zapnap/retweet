class Status
  include DataMapper::Resource

  ATTR_MAP = {
               :id                => :twitter_id,
               :text              => :text,
               :from_user         => :from_user_name,
               :from_user_id      => :from_user_id,
               :to_user           => :to_user_name,
               :to_user_id        => :to_user_id,
               :profile_image_url => :profile_image_url,
               :created_at        => :created_at
             }

  property :id,                Serial
  property :twitter_id,        Integer
  property :text,              String,   :length => 0..255
  property :from_user_id,      Integer
  property :from_user_name,    String,   :length => 0..255
  property :to_user_id,        Integer
  property :to_user_name,      String,   :length => 0..255
  property :profile_image_url, String,   :length => 0..255
  property :created_at,        DateTime

  validates_present    :twitter_id, :text, :from_user_id, :from_user_name, :created_at
  validates_is_unique  :twitter_id

  # return an array of random records (support same options as +all+)
  # ex: Status.random(10, :created_at.gte => Time.now - 86400, :limit => 100)
  def self.random(length = 10, options = {})
    self.all(options).randomize.slice(0, length)
  end

  # create a new record from Twitter status data
  def self.create_from_twitter(status_data)
    s = self.new
    ATTR_MAP.each { |k,v| s.send("#{v.to_s}=", status_data.send(k)) }
    s.save
    s
  end

  # updates the local status cache from Twitter, returns number of new messages
  def self.update
    count = 0
    begin
      SiteConfig.search_keywords.each do |keyword|
        Twitter::Search.new(keyword).each do |s|
          unless self.first(:twitter_id => s.id)
            self.create_from_twitter(s)
            count += 1
          end
        end
      end

    rescue SocketError => e
      puts e
    end

    count
  end
end
