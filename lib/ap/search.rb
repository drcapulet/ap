module AP
  class Search < API
    attr_reader :query, :search_type
    
    # Error class for when unsupported methords are called on searches that
    # don't have the seach_type to "request" (that is the default). This error
    # is railed on objects obtained by the similar(id) method
    class UnsupportedSearchMethod < StandardError; def to_s; "This method isn't supported for this search type"; end; end
    class InvalidGeocodinates < StandardError; def to_s; "Latitude must be between -90 and 90 and longitude must be between -180 and 180"; end; end
    
    # Returns a new Search object
    def initialize
      clear
      super
    end
    
    # Returns a new Search object that will search for articled
    # similar to the one provided by the id parameter
    # The id parameter will the same as the id returned by an AP::Article
    # object. Supports limited functionality compared to a standard object:
    #  - clear
    #  - geocode
    #  - location
    #  - sort_by_locaation
    #  - to_s
    #  - per_page
    #  - page
    #  - next_page?
    #  - next_page
    #  - fetch
    def self.similar(id)
      obj = self.new
      obj.instance_variable_set(:@search_type, "similar")
      obj.instance_variable_set(:@query, obj.query.merge!(AP.search_query_defaults).merge!({ :searchTerms => id }))
      return obj
    end
    
    # Resets every parameter of a Search object
    # When called upon a Search object with a search type of similar
    # it will reset it a request search
    def clear
      @query = {}
      @query[:searchTerms] = []
      @query[:startPage] = 1
      @query[:count] = 20
      @total_results = 0
      @search_type = "request"
      self
    end
    
    # Basic Keyword Search
    # A basic query contains one or more words and no operators.
    # Sample Query        Returned Results
    # Iraq                Returns all documents containing the word “Iraq” and related word variations, such as “Iraqi”, but not “Iran”.
    # iraq                Returns the same results as Iraq (case is ignored).
    # Obama Iraq Obama    Returns the same results as Obama Iraq (repeated words are ignored).
    # Example Usage:
    #   search.containing("obama")
    #   search.containing("iraq")
    #   search.contains("iraq")
    #   search.q("iraq")
    # Aliased as contains and q
    def containing(query)
      raise UnsupportedSearchMethod unless @search_type == "request"
      @query[:searchTerms] << query
      return self
    end
    alias :contains :containing
    alias :q :containing
    
    # Exact Keyword Search (quotation marks)
    # Sample Query          Returned Results
    # "Iraq"                Returns all documents containing the word “Iraq”. Since stemming is not applied to the words in quotation marks, the query will match “Iraq” but not “Iraqi”.
    # "iraq"                Returns the same results as Iraq (case is still ignored in quoted text).
    # "Barack Obama" Iraq   Returns all documents containing “Barack Obama” and “Iraq”. Stemming is applied to “Iraq”, so the query will match “Barack Obama announces Iraqi elections”, but will not match “President Obama visits Iraq”.
    # "The Who" Performed   Stop words are not ignored in the quoted text. This query will match “The Who performed at MSG”, but will not match “Who performed at MSG?”
    # Example Usage:
    # For the query "Iraq":
    #   search.exact("Iraq")
    # For the query "Barack Obama" Iraq:
    #   search.exact("Brack Obama")
    #   search.contains("Iraq")
    def exact(query)
      raise UnsupportedSearchMethod unless @search_type == "request"
      @query[:searchTerms] << "\"#{query}\""
      return self
    end
    
    # Wildcard search for one character
    # Sample Query        Returned Results
    # Ira?                This query matches any four-letter word beginning with “ira.” It matches “Iraq” and “Iran,” but does not match “Iris,” “IRA,” “miracle,” “IRAAM” or “Aardvark.”
    # Obama AND ira?      This search returns any document containing “Obama” and any four-letter word beginning with “ira.” This query will match “Obama visits Iraq” or “Obama visits Iran.” It will not match “Will Obama meet the IRA?”
    # Obama AND	"ira?"    Wildcards are considered even when the term is enclosed in quotation marks. This query is equivalent to Obama AND ira?
    # Example usage:
    # For the query Ira?
    #   search.matches("Ira")
    def matches(prefix)
      raise UnsupportedSearchMethod unless @search_type == "request"
      @query[:searchTerms] << prefix.to_s + "?"
      return self
    end
    
    # Matches words beginning with passed string
    # Sample Query    Returned Results
    # ira*            This query matches any word beginning with “ira.” It matches “Iraq,” “Iran,” “IRA” and “IRAAM.” It does not match “Iris,” “miracle” or “aardvark.”
    # Example usage:
    #   search.loose_match("ira")
    def loose_match(str) # loose match
      raise UnsupportedSearchMethod unless @search_type == "request"
      @query[:searchTerms] << str.to_s + "*"
      return self
    end
    
    # Filter search results to latitude & longitude
    # within a specific radius
    # Parameters:
    # - latitude: The latitude of the location. The range of possible values is -90 to 90.
    # - longitude: The longitude of the location. The range of possible values is -180 to 180. (Note: If both latitude and longitude are specified, they wil take priority over all other location parameters - for example the location method)
    # - radius: The distance in miles from the specified location. The default is 50
    # Example:
    #   search.geocode(37.760401, -122.416534)
    # The example above would limit results to the San Francisco bay area, shown by this map[http://www.freemaptools.com/radius-around-point.htm?clat=37.760401&clng=-122.41653400000001&r=80.47&lc=FFFFFF&lw=1&fc=00FF00]
    def geocode(latitude, longitude, radius = 50)
      raise InvalidGeocodinates unless (-90 <= latitude && latitude <= 90 && -180 <= longitude && longitude <= 180)
      @query[:latitude] = latitude
      @query[:longitude] = longitude
      @query[:radius] = radius
      return self
    end
    
    # Filter a search around a City/State/Zip Code
    # Valid combinations:
    # - US zip code
    # - City, State
    # - City, State, Zip
    # Note: If zip code is specified, it will take priority over city and state.
    # The options hash takes three parameters:
    # - :city
    # - :state should be in two letter form; e.g. TX for Texas, AZ for Arizona
    # - :zip_code
    # Examples:
    #   search.location(:city => "Fremont", :state => "CA", :zip_code => "94536")
    #   search.location(:city => "Los Angeles", :state => "CA")
    #   search.location(:zip_code => "99652")
    def location(opts = {})
      if opts[:city] && opts[:state] && opts[:zip_code]
        @query[:location] = opts[:city] + ", " + opts[:state] + ", " + opts[:zip_code].to_s
      elsif opts[:zip_code]
        @query[:location] = opts[:zip_code].to_s
      elsif opts[:city] && opts[:state]
        @query[:location] = opts[:city] + ", " + opts[:state]
      end
      return self
    end
    
    # Orders results by proximity to the specified location
    # Default parameter is true
    # Examples:
    #   search.sort_by_location # will sort by location
    #   search.sort_by_location(true) # same as above
    #   search.sort_by_location(false) # will not sort by proximity
    def sort_by_location(sort = true)
      @query[:sortByLocation] = sort
      return self
    end
    
    # Scopes all of the following commands in parentheses to specify order.
    # It yields itself during the block, so it's the exact same object you
    # have been working with
    # Examples:
    #   search.scoped do |s|
    #     s.contains("Obama")
    #     s.or()
    #     s.contains("Iraq")
    #   end
    #   search.and()
    #   search.contains("Iran")
    # Will produce the query: (Obama OR Iraq) AND Iran
    def scoped(&block)
      raise UnsupportedSearchMethod unless @search_type == "request"
      @query[:searchTerms] << "("
      yield self
      @query[:searchTerms] << ")"
      return self
    end
    
    # Returns the query represented in string form
    # the way it will be submitted to the api
    def to_s
      return @query[:searchTerms].join(" ")
    end
    
    # Represents the AND boolean operator in the query
    # Sample Query                  Returned Results
    # Obama AND Iraq AND election   Returns all documents containing all of the words “Obama,” “Iraq,” and “election.” This is equivalent to Obama Iraq Election.
    # Example:
    #   search.contains("Obama")
    #   search.and()
    #   search.contains("Iraq")
    # Produces: Obama AND Iraw
    def and
      raise UnsupportedSearchMethod unless @search_type == "request"
      @query[:searchTerms] << "AND" unless(@query[:searchTerms].last == "(" || @query[:searchTerms].last == nil || @query[:searchTerms].last == "OR" || @query[:searchTerms].last == "AND" || @query[:searchTerms].last == "AND NOT")
      return self
    end
    
    # Represents the OR boolean operator in the query
    # Sample Query      Returned Results
    # Obama OR Iraq     Returns all documents containing either “Obama” or “Iraq.” The query will match both “Barack Obama” and “Iraqi elections.”
    # Example:
    #   search.contains("Obama")
    #   search.or()
    #   search.contains("Iraq")
    # Produces: Obama OR Iraq
    def or
      raise UnsupportedSearchMethod unless @search_type == "request"
      @query[:searchTerms] << "OR" unless(@query[:searchTerms].last == "(" || @query[:searchTerms].last == nil || @query[:searchTerms].last == "OR" || @query[:searchTerms].last == "AND" || @query[:searchTerms].last == "AND NOT")
      return self
    end
    
    # Represents the AND NOT boolean operator in the query
    # Sample Query                    Returned Results
    # Obama AND Iraq AND NOT Iran     Returns all documents that contain both “Obama” and “Iraq,” but not “Iran.”
    # Example:
    #   search.contains("Obama")
    #   search.and()
    #   search.contains("Iraq")
    #   search.and_not()
    #   search.contains("Iran")
    # Produces: Obama AND Iraq AND NOT Iran
    def and_not
      raise UnsupportedSearchMethod unless @search_type == "request"
      @query[:searchTerms] << "AND NOT" unless(@query[:searchTerms].last == "(" || @query[:searchTerms].last == nil || @query[:searchTerms].last == "OR" || @query[:searchTerms].last == "AND" || @query[:searchTerms].last == "AND NOT")
      return self
    end
   
    # Sets the number of results to return per page
    # Defaults to 20
    def per_page(pp = 20)
      @query[:count] = pp
      return self
    end
    
    # Sets the page to the parameter so you can fetch it
    def page(p = 1)
      @query[:startPage] = p
      return self
    end
    
    # Returns whether or not there is a next page
    def next_page?
      return (@query[:startPage] * (@query[:count] + 1)) < @total_results
    end
    
    # Returns the next page if next_page? is true
    def next_page
      if next_page?
        @query[:startPage] += 1
        fetch
      end
    end
    alias :fetch_next_page :next_page
    
    # Fetches and parses the search response. An array of AP::Article objects
    # are returned
    # Example:
    #   search.contains("Obama").and.contains("Iraq").fetch
    def fetch
      data = self.class.get("/v2/search.svc/#{@search_type}/", :query => @query.merge({ :searchTerms => CGI.escape(@query[:searchTerms].join(" ")) }))
      r = data["feed"]["entry"].collect { |e| AP::Article.new_from_api_data(e) }
      @total_results = data["feed"]["opensearch:totalResults"].to_i
      return r
    end
  end
end