require 'spec_helper'

describe AP::API do
  describe "base_uri" do
    it "should have the correct endpoint" do
      AP::API.base_uri.should == "http://developerapi.ap.org"
    end
  end
  
  describe "format" do
    it "should have the custom ap_xml format" do
      AP::API.format.should be(:ap_xml)
    end
  end
  
  describe "API key" do
    it "should have a apiKey key in the default params hash" do
      AP::API.new
      AP::API.default_params.keys.should include(:apiKey)
    end
  end
end