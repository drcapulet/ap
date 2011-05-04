module AP
  class Article
    attr_accessor :id, :title, :authors, :tags, :link, :content, :updated
    
    # Creates a new AP::Article object given the following attributes
    # - id: the article id as reported by the AP
    # - title: the title of the article
    # - authors: an Array of the name(s) of the author(s) of this article
    # - tags: and array of tags or categories that have been attached to this article
    # - link: string with the hosted version on the AP site
    # - content: the article content
    # - updated: Time object of when the article was last updated
    def initialize(opts = {})
      @id = opts[:id]
      @title = opts[:title]
      @tags = opts[:tags] || []
      @authors = opts[:authors] || []
      @link = opts[:link]
      @content = opts[:content]
      @updated = opts[:updated]
    end
    
    # Creates a new object from data returned by the API
    def self.new_from_api_data(data)
      if data["author"].is_a?(Hash)
        authors = [ data["author"]["name"] ]
      elsif data["author"].is_a?(Array)
        authors = data["author"].collect{ |x| x["name"] }
      end
      categories = data["category"] ? data["category"].collect { |x| x["label"] } : []
      return new(:id => data["id"].split(":").last, :title => data["title"], :authors => authors, :tags => categories, :link => data["link"]["href"], :content => data["content"], :updated => Time.parse(data["updated"]))
    end
    
    # Returns a search object that when fetched, will find articles
    # similar to this one. Refer to AP::Search for more information
    def similar
      return AP::Search.similar(@id)
    end
  end
end