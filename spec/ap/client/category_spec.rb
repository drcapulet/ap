require 'spec_helper'

describe AP::Client::Category do
  context "with an API key" do
    before do
      AP.configure do |c|
        c.api_key = "api"
      end
    end
    
    describe ".categories" do
      before do
        stub_get("/v2/categories.svc/?apiKey=api").to_return(:body => fixture("categories.xml"), :headers => {:content_type => "application/xml; charset=utf-8"})
      end
    
      it "should map API data to objects" do
        AP.categories.size.should == 52
      end
    
      {:id => "31990", :content => "AP Online Top General Short Headlines", :title => "AP Online Top General Short Headlines", :updated => Time.parse("2011-04-23T05:55:23Z") }.each do |e, v|
        it "should map the API data to the attribute #{e}" do
          AP.categories.first.send(e).should == v
        end
      end
    end
  
    describe ".category(id)" do
      before do
        stub_get("/v2/categories.svc/31990?apiKey=api").to_return(:body => fixture("categories-31990.xml"), :headers => {:content_type => "application/xml; charset=utf-8"})
      end
    
      it "should map API data to objects" do
        AP.category(31990).size.should == 10
      end
    
      {
        :id => "772cbfbd-eb16-4527-882e-48d4fb21ad35",
        :title => "Tornado causes injuries at St. Louis airport",
        :updated => Time.parse("2011-04-23T05:48:58Z"),
        :authors => ["JIM SALTER", "JIM SUHR"],
        :link => "http://hosted2.ap.org/APDEFAULT/Article_2011-04-23-US-Missouri-Storms/id-p772cbfbdeb164527882e48d4fb21ad35",
        :tags => [ "Property damage", "Tornados", "Power outages", "Storms", "Natural disasters", "Weather", "Air travel disruptions", "Emergency management",
                      "Injuries", "General news", "Tornados", "Accidents and disasters", "Transportation", "Government and politics", "Health", "Francis Slay",
                      "Jay Nixon", "Maryland", "St. Louis", "Missouri", "United States", "North America"]
      }.each do |e, v|
        it "should map the API data to the attribute #{e}" do
          AP.category(31990).first.send(e).should == v
        end
      end
    end
  end
  
  context "without an API key" do
    before do
      AP.configure do |c|
        c.api_key = nil
      end
    end
    
    describe ".categories" do
      it "should raise a MissingAPIKeyError" do
        stub_get("/v2/categories.svc/?apiKey=api").to_return(:status => 200, :body => "403 Developer Inactive", :headers => {})
        expect { AP.categories }.to raise_error(AP::API::MissingAPIKeyError)
      end
    end
  
    describe ".category(id)" do
      it "should raise a MissingAPIKeyError" do
        stub_get("/v2/categories.svc/5?apiKey=api").to_return(:status => 200, :body => "", :headers => {})
        expect { AP.category(5) }.to raise_error(AP::API::MissingAPIKeyError)
      end
    end
  end
end