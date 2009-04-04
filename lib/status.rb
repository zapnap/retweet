class Status < CouchRest::ExtendedDocument
  include CouchRest::Validation
  use_database CouchRest.database!((SiteConfig.url_base_db || '') + SiteConfig.db_name)
  unique_id :twitter_id

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

  property :twitter_id
  property :text
  property :from_user_id
  property :from_user_name
  property :to_user_id
  property :to_user_name
  property :profile_image_url
  property :created_at

  validates_present :twitter_id, :text, :from_user_id, :from_user_name, :created_at
  #validates_is_unique :twitter_id

  view_by :twitter_id
  view_by :created_at, :descending => true

  # return an array of random records (support same options as standard CouchRest views)
  # ex: Status.random(10, :limit => 100) would choose 10 random records from the most recent 100
  def self.random(length = 10, options = {})
    self.by_created_at(options).randomize.slice(0, length)
  end

  def self.count
    self.database.documents['total_rows']
  end

  # create a new record from Twitter status data
  def self.create_from_twitter(status_data)
    s = self.new
    ATTR_MAP.each { |k,v| s.send("#{v.to_s}=", status_data.send(k).to_s) }
    s.save
    s
  end

  # updates the local status cache from Twitter, returns number of new messages
  def self.update
    count = 0
    begin
      SiteConfig.search_keywords.each do |keyword|
        Twitter::Search.new(keyword).each do |s|
          if self.by_twitter_id(:key => s.id.to_s).empty?
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
