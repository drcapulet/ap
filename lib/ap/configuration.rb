module AP
  # thanks to jnunemaker's twitter gem for this
  # Defines constants and methods related to configuration
  module Configuration
    # An array of valid keys in the options hash
    VALID_OPTIONS_KEYS = [
      :api_key,
      :user_agent,
      :search_query_defaults].freeze
      
    # @private
    attr_accessor *VALID_OPTIONS_KEYS

    # When this module is extended, set all configuration options to their default values
    def self.extended(base)
      base.reset
    end

    # Convenience method to allow configuration options to be set in a block
    def configure
      yield self
    end

    # Create a hash of options and their values
    def options
      options = {}
      VALID_OPTIONS_KEYS.each{|k| options[k] = send(k) }
      options
    end
    
    DEFAULT_API_KEY = nil
    
    DEFAULT_USER_AGENT = "Ruby AP Gem #{::AP::VERSION}".freeze
    
    DEFAULT_SEARCH_SETTINGS = {
      :count => 20
    }.freeze

    # Reset all configuration options to defaults
    def reset
      self.api_key                = DEFAULT_API_KEY
      self.user_agent             = DEFAULT_USER_AGENT
      self.search_query_defaults  = DEFAULT_SEARCH_SETTINGS
      self
    end
  end
end