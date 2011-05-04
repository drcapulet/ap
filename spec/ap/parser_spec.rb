require 'spec_helper'

describe HTTParty::Parser do
  
  it "should add CDATA tags and parse correctly" do
    parsed = HTTParty::Parser.call("<feed xmlns=\"http://www.w3.org/2005/Atom\"><entry><content type=\"xhtml\"><div xmlns=\"http://www.w3.org/1999/xhtml\"><div class=\"hnews hentry item\"></div></div></content></entry></feed>", :ap_xml)
    parsed["feed"]["entry"]["content"].should == "<div xmlns=\"http://www.w3.org/1999/xhtml\"><div class=\"hnews hentry item\"></div></div>"
  end
  
  it "shouldn't add CDATA when not needed" do
    parsed = HTTParty::Parser.call("<feed xmlns=\"http://www.w3.org/2005/Atom\"><entry><content type=\"xhtml\"><![CDATA[<div xmlns=\"http://www.w3.org/1999/xhtml\"><div class=\"hnews hentry item\"></div></div>]]></content></entry></feed>", :ap_xml)
    parsed["feed"]["entry"]["content"].should == "<div xmlns=\"http://www.w3.org/1999/xhtml\"><div class=\"hnews hentry item\"></div></div>"
  end
end