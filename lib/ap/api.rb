module AP
  class API
    include HTTParty
    format :ap_xml
    base_uri 'developerapi.ap.org'

    class MissingAPIKeyError < StandardError; def to_s; "You didn't provide an API key"; end; end

    def initialize(options = {})
      options = AP.options.merge(options)
      self.class.default_params :apiKey => options[:api_key]
    end    
    
    def self.get(*args)
      raise MissingAPIKeyError if default_params.nil? || default_params[:apiKey].nil? || default_params[:apiKey].empty?
      super
    end
  end 
end