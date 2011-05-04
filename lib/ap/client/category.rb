module AP
  class Client
    module Category
      # Returns an array of AP::Category objects representing the news categories
      def categories
        self.class.get("/v2/categories.svc/")["feed"]["entry"].collect { |e| AP::Category.new_from_api_data(e) }
      end

      # Returns an array of AP::Articles objects representing recent news in a category
      def category(id)
        self.class.get("/v2/categories.svc/#{id}")["feed"]["entry"].collect { |e| AP::Article.new_from_api_data(e) }
      end
    end
  end
end