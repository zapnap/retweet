require "#{File.dirname(__FILE__)}/spec_helper"

describe 'status' do
  before(:each) do
    @status = Status.new(valid_attributes)
  end

  specify 'should be valid' do
    @status.should be_valid
  end

  specify 'should require a twitter (status) id' do
    @status.twitter_id = nil
    @status.should_not be_valid
    @status.errors[:twitter_id].should include("Twitter must not be blank")
  end

  specify 'should require status text' do
    @status.text = nil
    @status.should_not be_valid
    @status.errors[:text].should include("Text must not be blank")
  end

  specify 'should require a user name' do
    @status.from_user_name = nil
    @status.should_not be_valid
    @status.errors[:from_user_name].should include("From user name must not be blank")
  end

  specify 'should require a user id' do
    @status.from_user_id = nil
    @status.should_not be_valid
    @status.errors[:from_user_id].should include("From user must not be blank")
  end

  specify 'should require a create timestamp' do
    @status.created_at = nil
    @status.should_not be_valid
    @status.errors[:created_at].should include("Created at must not be blank")
  end

  specify 'should require a unique twitter (status) id' do
    @status.save
    @status = Status.new(valid_attributes)
    @status.should_not be_valid
    @status.errors[:twitter_id].should include("Twitter is already taken")
  end

  specify 'should create new status from Twitter data' do
    lambda do
      Status.create_from_twitter(status_data)
    end.should change(Status, :count)
  end

  specify 'should map attributes from Twitter data' do
    Status.create_from_twitter(status_data)
    Status.first.twitter_id.should == 1002
  end

  specify 'should return random records' do
    @statuses = [mock('Status 1'), mock('Status 2'), mock('Status 3')]
    Status.should_receive(:all).with(:limit => 3).and_return(@statuses)
    @statuses.should_receive(:randomize).and_return(@statuses.reverse)
    Status.random(2, :limit => 3).should == @statuses.reverse.slice(0,2)
  end

  describe 'when updating from Twitter' do
    before(:each) do
      Twitter::Search.stub!(:new).and_return([@status_data = status_data])
      SiteConfig.search_keywords = ['keyword_one']
    end

    specify 'should retrieve remote data' do
      Status.should_receive(:first).with(:twitter_id => 1002).and_return(false)
      Status.should_receive(:create_from_twitter).with(@status_data).and_return(true)
      Status.update
    end

    specify 'should not save update if status has already been recorded' do
      Status.should_receive(:first).with(:twitter_id => 1002).and_return(true)
      Status.should_not_receive(:create_from_twitter)
      Status.update
    end

    specify 'should query twitter API for each keyword' do
      SiteConfig.search_keywords = ['keyword_one', 'keyword_two']
      Twitter::Search.should_receive(:new).twice
      Status.stub!(:first).and_return(true)
      Status.update
    end
  end

  def valid_attributes
    { 
      :twitter_id     => 1001,
      :text           => 'frogurt is delicious!',
      :from_user_name => 'zapnap',
      :from_user_id   => '83034',
      :created_at     => Time.now
    }
  end

  def status_data
    OpenStruct.new(
      :id => 1002,
      :text => 'did i mention that frogurt is delicious?',
      :from_user => 'zapnap',
      :from_user_id => '83034',
      :to_user => '',
      :to_user_id => '',
      :created_at => Time.now
    )
  end
end
