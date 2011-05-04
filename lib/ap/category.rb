module AP
  class Category
    attr_accessor :id, :title, :content, :updated
    
    
    # Creates a new AP::Category object given the following attributes
    # - id: the category id as reported by the AP
    # - title: the title/name of the category
    # - content: the category content. most often is the same as the title
    # - updated: Time object of when the article was last updated
    def initialize(opts = {})
      @id = opts[:id]
      @title = opts[:title]
      @content = opts[:content]
      @updated = opts[:updated]
    end
    
    # Creates a new object from data returned by the API
    def self.new_from_api_data(data)
      return new(:id => data["id"].split(":").last, :title => data["title"], :content => data["content"], :updated => Time.parse(data["updated"]))
    end
    
    # Returns an array of AP::Article objects that represent recent news in this category
    def articles
      return AP.category(@id)
    end
  end
end