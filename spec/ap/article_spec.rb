require 'spec_helper'

describe AP::Article do
  describe "attributes" do
    [:id, :title, :authors, :tags, :link, :content, :updated].each do |e|
      it "should have a #{e} attribute" do
        @article = AP::Article.new
        @article.should respond_to(e)
      end
    end
    
    params_hash = {:id => "random", :title => "a title", :authors => "", :tags => ["A tag"], :link => "http://google.com", :content => "<div>content</div>", :updated => Time.now}
    params_hash.each do |e, v|
      it "should have the correct value for #{e}" do
        @article = AP::Article.new(params_hash)
        @article.send(e).should == v
      end
    end    
  end
  
  describe "creating an object from API data" do
    before do
      @api_data = {
        "id" => "urn:blah:blahblah",
        "title" => "Hello",
        "author" => [],
        "category" => [ {"label" => "Tag 1"}, {"label" => "Tag 2" } ],
        "link" => { "href" => "http://google.com" },
        "content" => "<div>content</div>",
        "updated" => "2011-04-23T06:00:39Z"
      }
      @parsed_data = {
        "id" => "blahblah",
        "title" => "Hello",
        "authors" => [],
        "tags" => ["Tag 1", "Tag 2"],
        "link" => "http://google.com",
        "content" => "<div>content</div>",
        "updated" => Time.parse("2011-04-23T06:00:39Z")
      }
    end
    
    describe "should return a proper object" do
      before do
        @article = AP::Article.new_from_api_data(@api_data)
      end
      
      [:id, :title, :authors, :tags, :link, :content, :updated].each do |e|
        it "with the correct value for #{e.to_s}" do
          @article.send(e).should == @parsed_data[e.to_s]
        end
      end
    end
    
    describe "should properly differentiate between one and multiple authors" do
      before do
        @api_data["author"] = {"name" => "Joe"}
        @parsed_data["authors"] = ["Joe"]
        @article = AP::Article.new_from_api_data(@api_data)
      end
      
      [:id, :title, :authors, :tags, :link, :content, :updated].each do |e|
        it "with the correct value for #{e.to_s}" do
          @article.send(e).should == @parsed_data[e.to_s]
        end
      end
    end
    
    describe "should support multiple authors" do
      before do
        @api_data["author"] = [{"name" => "Joe"}, {"name" => "Bob"}, {"name" => "Jane"}]
        @parsed_data["authors"] = ["Joe", "Bob", "Jane"]
        @article = AP::Article.new_from_api_data(@api_data)
      end
      
      [:id, :title, :authors, :tags, :link, :content, :updated].each do |e|
        it "with the correct value for #{e.to_s}" do
          @article.send(e).should == @parsed_data[e.to_s]
        end
      end
    end
  end
end