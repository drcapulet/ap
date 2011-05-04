module AP
  # Wrapper for the Associated Press API
  class Client < API
    require 'ap/client/category'
    
    include AP::Client::Category
  end
end