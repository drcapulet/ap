require 'spec_helper'

describe AP::Category do
  describe "attributes" do
    [:id, :title, :content, :updated].each do |e|
      it "should have a #{e} attribute" do
        @category = AP::Category.new
        @category.should respond_to(e)
      end
    end
    
    params_hash = {:id => "random", :title => "a title", :content => "<div>content</div>", :updated => Time.now }
    params_hash.each do |e, v|
      it "should have the correct value for #{e}" do
        @category = AP::Category.new(params_hash)
        @category.send(e).should == v
      end
    end    
  end
  
  describe "creating an object from API data" do
    before do
      @api_data = {
        "id" => "urn:uuid:31990",
        "title" => "Hello",
        "content" => "<div>content</div>",
        "updated" => "2011-04-23T06:00:39Z"
      }
      @parsed_data = {
        "id" => "31990",
        "title" => "Hello",
        "content" => "<div>content</div>",
        "updated" => Time.parse("2011-04-23T06:00:39Z")
      }
    end
    
    describe "should return a proper object" do
      before do
        @category = AP::Category.new_from_api_data(@api_data)
      end
      
      [:id, :title, :content, :updated].each do |e|
        it "with the correct value for #{e.to_s}" do
          @category.send(e).should == @parsed_data[e.to_s]
        end
      end
    end
    
  end
end