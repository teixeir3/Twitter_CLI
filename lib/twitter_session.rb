require 'json'
require 'rest-client'
require 'addressable/uri'
require 'oauth'
require 'yaml'

class TwitterSession
  # attr_accessible :title, :body

  CONSUMER = OAuth::Consumer.new(
    CONSUMER_KEY, CONSUMER_SECRET, :site => "https://twitter.com")

  request_token = CONSUMER.get_request_token
  authorize_url = request_token.authorize_url

  p authorize_url

  # Both `::get` and `::post` should return the parsed JSON body.
  def self.get(path, query_values)
    RestClient.get(Addressable::URI.new(:scheme => "https", :host => "api.twitter.com", :path => path, :query_values => query_values))
  end

  def self.post(path, req_params)
    RestClient.post(Addressable::URI.new(:scheme => "http", :host => "www.twitter.com", :path => path, :req_params => req_params))
  end

  def self.access_token
      # Load from file or request from Twitter as necessary. Store token
      # in class instance variable so it is repeatedly re-read from disk
      # unnecessarily.
  end

  def self.request_access_token
    # Put user through authorization flow; save access token to file
  end

  def self.path_to_url(path, query_values = nil)
    # All Twitter API calls are of the format
    # "https://api.twitter.com/1.1/#{path}.json". Use
    # `Addressable::URI` to build the full URL from just the
    # meaningful part of the path (`statuses/user_timeline`)
  end
end
