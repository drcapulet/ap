require 'spec_helper'

describe AP::Search do
  # similar queries
  describe "similar query" do
    before do
      @search = AP::Article.new(:id => "5").similar
    end
    
    describe ".clear" do
      before do
        @search.clear
      end
      
      it "should reset the search type to request" do
        @search.search_type.should == "request"
      end
      
      it "should reset the search terms" do
        @search.query[:searchTerms].should == []
      end
      
      it "should reset the start page" do
        @search.query[:startPage].should == 1
      end
      
      it "should reset the count" do
        @search.query[:count].should == 20
      end
    end
    
    describe ".containing" do
      it "should raise an UnsupportedSearchMethod error" do
        expect { @search.containing("Obama") }.to raise_error(AP::Search::UnsupportedSearchMethod)
      end
    end
    
    describe ".exact" do
      it "should raise an UnsupportedSearchMethod error" do
        expect { @search.exact("Obama") }.to raise_error(AP::Search::UnsupportedSearchMethod)
      end
    end
    
    describe ".matches" do
      it "should raise an UnsupportedSearchMethod error" do
         expect { @search.matches("Ira") }.to raise_error(AP::Search::UnsupportedSearchMethod)
      end
    end
    
    describe ".loose_match" do
      it "should raise an UnsupportedSearchMethod error" do
        expect { @search.loose_match("ira") }.to raise_error(AP::Search::UnsupportedSearchMethod)
      end
    end
    
    describe ".geocode" do
      it "should properly set the geocode attributes given lat & long" do
        @search.geocode(50, -125)
        @search.query[:latitude].should == 50
        @search.query[:longitude].should == -125
        @search.query[:radius].should == 50
      end
      
      it "should properly set the geocode attributes given lat, long & radius" do
        @search.geocode(50, -125, 35)
        @search.query[:latitude].should == 50
        @search.query[:longitude].should == -125
        @search.query[:radius].should == 35
      end
      
      it "should raise a InvalidGeocodinates when latitude is invalid" do
        expect { @search.geocode(100, 0) }.to raise_error(AP::Search::InvalidGeocodinates)
      end
      
      it "should raise a InvalidGeocodinates when longitude is invalid" do
        expect { @search.geocode(50, 200) }.to raise_error(AP::Search::InvalidGeocodinates)
      end
      
      it "should raise a InvalidGeocodinates when longitude and latitude are invalid" do
        expect { @search.geocode(-95, 200) }.to raise_error(AP::Search::InvalidGeocodinates)
      end
    end
    
    describe ".location" do
      it "should set City, State & ZIP code when given" do
        @search.location(:zip_code => 12345, :city => "Albany", :state => "NY")
        @search.query[:location].should == "Albany, NY, 12345"
      end
      
      it "should set ZIP code when given" do
        @search.location(:zip_code => 12345)
        @search.query[:location].should == "12345"
      end
      
      it "should only set ZIP code if City is also given" do
        @search.location(:zip_code => 12345, :city => "Albany")
        @search.query[:location].should == "12345"
      end
      
      it "should only set ZIP code if State is also given" do
        @search.location(:zip_code => 12345, :state => "NY")
        @search.query[:location].should == "12345"
      end
      
      it "should set City & State if both are given" do
        @search.location(:city => "Albany", :state => "NY")
        @search.query[:location].should == "Albany, NY"
      end
    end
    
    describe ".sort_by_location" do
      it "should default to true" do
        @search.sort_by_location
        @search.query[:sortByLocation].should be(true)
      end
      
      it "should take the parameter true" do
        @search.sort_by_location(true)
        @search.query[:sortByLocation].should be(true)
      end
      
      it "should take the parameter false" do
        @search.sort_by_location(false)
        @search.query[:sortByLocation].should be(false)
      end
    end
    
    describe ".scoped" do
      it "should raise an UnsupportedSearchMethod error" do
        expect { @search.scoped do |c|; end; }.to raise_error(AP::Search::UnsupportedSearchMethod)
      end
    end
    
    describe ".and" do
      it "should raise an UnsupportedSearchMethod error" do
        expect { @search.and }.to raise_error(AP::Search::UnsupportedSearchMethod)
      end
    end
    
    describe ".or" do
      it "should raise an UnsupportedSearchMethod error" do
        expect { @search.or }.to raise_error(AP::Search::UnsupportedSearchMethod)
      end
    end
    
    describe ".and_not" do
      it "should raise an UnsupportedSearchMethod error" do
        expect { @search.and_not }.to raise_error(AP::Search::UnsupportedSearchMethod)
      end
    end
    
    describe ".per_page" do
      it "should default to 20" do
        @search.per_page
        @search.query[:count].should == 20
      end
      
      it "should set the sent value" do
        @search.per_page(39)
        @search.query[:count].should == 39
      end
    end
    
    describe ".page" do
      it "should default to 1" do
        @search.page
        @search.query[:startPage].should == 1
      end
      
      it "should move to the sent page" do
        @search.page(5)
        @search.query[:startPage].should == 5
      end
    end
  end
  
  # request queries
  describe "request query" do
    before do
      @search = AP::Search.new
    end
    
    describe ".clear" do
      before do
        @search.clear
      end
      
      it "should keep the search type at request" do
        @search.search_type.should == "request"
      end
      
      it "should reset the search terms" do
        @search.query[:searchTerms].should == []
      end
      
      it "should reset the start page" do
        @search.query[:startPage].should == 1
      end
      
      it "should reset the count" do
        @search.query[:count].should == 20
      end
    end
    
    describe ".containing" do
      it "should append the string the the query" do
        @search.containing("Obama")
        @search.query[:searchTerms].first.should == "Obama"
      end
    end
    
    describe ".exact" do
      it "should append the string the the query" do
        @search.exact("Obama")
        @search.query[:searchTerms].first.should == "\"Obama\""
      end
    end
    
    describe ".matches" do
      it "should append the string the the query" do
        @search.matches("Ira")
        @search.query[:searchTerms].first.should == "Ira?"
      end
    end
    
    describe ".loose_match" do
      it "should append the string the the query" do
        @search.loose_match("ira")
        @search.query[:searchTerms].first.should == "ira*"
      end
    end
    
    describe ".geocode" do
      it "should properly set the geocode attributes given lat & long" do
        @search.geocode(50, -125)
        @search.query[:latitude].should == 50
        @search.query[:longitude].should == -125
        @search.query[:radius].should == 50
      end
      
      it "should properly set the geocode attributes given lat, long & radius" do
        @search.geocode(50, -125, 35)
        @search.query[:latitude].should == 50
        @search.query[:longitude].should == -125
        @search.query[:radius].should == 35
      end
      
      it "should raise a InvalidGeocodinates when latitude is invalid" do
        expect { @search.geocode(100, 0) }.to raise_error(AP::Search::InvalidGeocodinates)
      end
      
      it "should raise a InvalidGeocodinates when longitude is invalid" do
        expect { @search.geocode(50, 200) }.to raise_error(AP::Search::InvalidGeocodinates)
      end
      
      it "should raise a InvalidGeocodinates when longitude and latitude are invalid" do
        expect { @search.geocode(-95, 200) }.to raise_error(AP::Search::InvalidGeocodinates)
      end
    end
    
    describe ".location" do
      it "should set City, State & ZIP code when given" do
        @search.location(:zip_code => 12345, :city => "Albany", :state => "NY")
        @search.query[:location].should == "Albany, NY, 12345"
      end
      
      it "should set ZIP code when given" do
        @search.location(:zip_code => 12345)
        @search.query[:location].should == "12345"
      end
      
      it "should only set ZIP code if City is also given" do
        @search.location(:zip_code => 12345, :city => "Albany")
        @search.query[:location].should == "12345"
      end
      
      it "should only set ZIP code if State is also given" do
        @search.location(:zip_code => 12345, :state => "NY")
        @search.query[:location].should == "12345"
      end
      
      it "should set City & State if both are given" do
        @search.location(:city => "Albany", :state => "NY")
        @search.query[:location].should == "Albany, NY"
      end
    end
    
    describe ".sort_by_location" do
      it "should default to true" do
        @search.sort_by_location
        @search.query[:sortByLocation].should be(true)
      end
      
      it "should take the parameter true" do
        @search.sort_by_location(true)
        @search.query[:sortByLocation].should be(true)
      end
      
      it "should take the parameter false" do
        @search.sort_by_location(false)
        @search.query[:sortByLocation].should be(false)
      end
    end
    
    describe ".and" do
      it "should append AND only if something already is in the query" do
        @search.contains("Obama").and
        @search.query[:searchTerms].last.should == "AND"
      end
      
      it "shouldn't append if the query is empty" do
        @search.and
        @search.query[:searchTerms].last.should == nil
      end
      
      it "shouldn't append if the last item in the query was AND" do
        @search.contains("Obama").and.and
        @search.query[:searchTerms].first.should == "Obama"
        @search.query[:searchTerms].last.should == "AND"
        @search.query[:searchTerms].size.should == 2
      end
      
      it "shouldn't append if the last item in the query was OR" do
        @search.contains("Obama").or.and
        @search.query[:searchTerms].first.should == "Obama"
        @search.query[:searchTerms].last.should == "OR"
        @search.query[:searchTerms].size.should == 2
      end
      
      it "shouldn't append if the last item in the query was AND NOT" do
        @search.contains("Obama").and_not.and
        @search.query[:searchTerms].first.should == "Obama"
        @search.query[:searchTerms].last.should == "AND NOT"
        @search.query[:searchTerms].size.should == 2
      end
    end
    
    describe ".or" do
      it "should append OR only if something already is in the query" do
        @search.contains("Obama").or
        @search.query[:searchTerms].last.should == "OR"
      end

      it "shouldn't append if the query is empty" do
        @search.or
        @search.query[:searchTerms].last.should == nil
      end

      it "shouldn't append if the last item in the query was OR" do
        @search.contains("Obama").or.or
        @search.query[:searchTerms].first.should == "Obama"
        @search.query[:searchTerms].last.should == "OR"
        @search.query[:searchTerms].size.should == 2
      end
      it "shouldn't append if the last item in the query was AND" do
        @search.contains("Obama").and.or
        @search.query[:searchTerms].first.should == "Obama"
        @search.query[:searchTerms].last.should == "AND"
        @search.query[:searchTerms].size.should == 2
      end
      
      it "shouldn't append if the last item in the query was AND NOT" do
        @search.contains("Obama").and_not.or
        @search.query[:searchTerms].first.should == "Obama"
        @search.query[:searchTerms].last.should == "AND NOT"
        @search.query[:searchTerms].size.should == 2
      end
    end
    
    describe ".and_not" do
      it "should append AND NOT only if something already is in the query" do
        @search.contains("Obama").and_not
        @search.query[:searchTerms].last.should == "AND NOT"
      end

      it "shouldn't append if the query is empty" do
        @search.and_not
        @search.query[:searchTerms].last.should == nil
      end
      
      it "shouldn't append if the last item in the query was AND" do
        @search.contains("Obama").and.and_not
        @search.query[:searchTerms].first.should == "Obama"
        @search.query[:searchTerms].last.should == "AND"
        @search.query[:searchTerms].size.should == 2
      end
      
      it "shouldn't append if the last item in the query was OR" do
        @search.contains("Obama").or.and_not
        @search.query[:searchTerms].first.should == "Obama"
        @search.query[:searchTerms].last.should == "OR"
        @search.query[:searchTerms].size.should == 2
      end
      
      it "shouldn't append if the last item in the query was AND NOT" do
        @search.contains("Obama").and_not.and_not
        @search.query[:searchTerms].first.should == "Obama"
        @search.query[:searchTerms].last.should == "AND NOT"
        @search.query[:searchTerms].size.should == 2
      end
    end
    
    describe ".per_page" do
      it "should default to 20" do
        @search.per_page
        @search.query[:count].should == 20
      end
      
      it "should set the sent value" do
        @search.per_page(39)
        @search.query[:count].should == 39
      end
    end
    
    describe ".page" do
      it "should default to 1" do
        @search.page
        @search.query[:startPage].should == 1
      end
      
      it "should move to the sent page" do
        @search.page(5)
        @search.query[:startPage].should == 5
      end
    end
  end
  
  context "without an API key" do
    before do
      @search = AP::Search.new      
    end
    
    it "should raise a MissingAPIKeyError" do
      @search.contains("Obama")
      expect { @search.fetch }.to raise_error(AP::API::MissingAPIKeyError)
    end
  end
  
  context "with an API key" do
    before do
      AP.configure do |c|
        c.api_key = "api"
      end
      @search = AP::Search.new
      stub_get("/v2/search.svc/request/?apiKey=api&count=20&searchTerms=Obama&startPage=1").to_return(:body => fixture("search-obama.xml"), :headers => {:content_type => "application/xml; charset=utf-8"})
    end
    
    it "should fetch and return" do
      @search.contains("Obama")
      @search.fetch.size.should == 20
    end
  end
end