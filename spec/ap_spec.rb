require 'spec_helper'

describe AP do
  it "should respond to client" do
    AP.respond_to?(:client).should be(true)
    AP.client.is_a?(AP::Client).should be(true)
  end
end
