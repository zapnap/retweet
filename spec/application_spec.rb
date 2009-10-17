require "#{File.dirname(__FILE__)}/spec_helper"

describe 'main application' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  before(:each) do
    @status = mock('Status', :null_object => true)
    @status.stub!(:text).and_return("Here is some text")
  end

  specify "should show the default index page" do
    get '/'
    last_response.should be_ok
    last_response.body.should have_tag('title', /#{SiteConfig.title}/)
  end

  specify 'should show the most recent statuses' do
    Status.should_receive(:random).and_return([@status])
    get '/'
    last_response.should be_ok
    last_response.body.should have_tag('li', /#{@status.text}/, :count => 1)
  end
end
