require "#{File.dirname(__FILE__)}/spec_helper"

describe 'main application' do
  include Sinatra::Test

  before(:each) do
    @status = mock('Status', :null_object => true)
    @status.stub!(:text).and_return("Here is some text")
  end

  specify "should show the default index page" do
    get '/'
    @response.should be_ok
    @response.body.should match(/#{SiteConfig.title}/)
  end

  specify 'should show the most recent statuses' do
    Status.should_receive(:random).and_return([@status])
    get '/'
    @response.should be_ok
    @response.should have_tag('li', /#{@status.text}/, :count => 1)
  end
end
