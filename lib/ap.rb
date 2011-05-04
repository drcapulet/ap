require 'httparty'
require 'crack/xml'
require 'cgi'

require 'ap/version'
require 'ap/parser'
require 'ap/category'
require 'ap/article'
require 'ap/api'
require 'ap/client'
require 'ap/configuration'
require 'ap/search'


module AP
  extend Configuration
  
  # Alias for AP::Client.new
  def self.client(options = {})
    AP::Client.new(options)
  end

  def self.method_missing(method, *args, &block)
    return super unless client.respond_to?(method)
    client.send(method, *args, &block)
  end

  def self.respond_to?(method, include_private = false)
    client.respond_to?(method, include_private) || super(method, include_private)
  end
end