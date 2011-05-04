require 'spec_helper'

describe AP::Client do
  describe "includes AP::Client::Category" do
    before do
      @client = AP::Client.new
    end
    
    [:categories, :category].each do |e|
      it "should respond to #{e}" do
        @client.should respond_to(e)
      end
    end
  end
end