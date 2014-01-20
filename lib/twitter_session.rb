require 'json'
require 'rest_client'
require 'addressable/uri'
require 'oauth'
require 'yaml'
require 'launchy'
require 'twitter_keys.rb'

class TwitterSession
  # attr_accessible :title, :body
  TOKEN_FILE = "access_token.yml"

  CONSUMER = OAuth::Consumer.new(
      TwitterKeys::CONSUMER_KEY, TwitterKeys::CONSUMER_SECRET, :site => "https://twitter.com")


  # Both `::get` and `::post` should return the parsed JSON body.
  def self.get(path, query_values)
    self.access_token if @access_token.nil?
    JSON.parse(@access_token.get(self.path_to_url(path, query_values)).body)
  end

  def self.post(path, req_params)
    self.access_token if @access_token.nil?
    JSON.parse(@access_token.post(self.path_to_url(path, req_params)).body)
  end

  def self.access_token
      # Load from file or request from Twitter as necessary. Store token
      # in class instance variable so it is repeatedly re-read from disk
      # unnecessarily.
    if File.exist?(TOKEN_FILE)
      # reload token from file
      @access_token = File.open(TOKEN_FILE) { |f| YAML.load(f) }
    else
      # copy the old code that requested the access token into a
      # `request_access_token` method.
      @access_token = self.request_access_token
    end
  end

  def self.request_access_token
    # Put user through authorization flow; save access token to file
    access_token = self.get_token
    File.open(TOKEN_FILE, "w") { |f| YAML.dump(access_token, f) }

    access_token
  end

  def self.get_token
    # We can serialize token to a file, so that future requests don't
    # need to be reauthorized.

    request_token = CONSUMER.get_request_token
    authorize_url = request_token.authorize_url

    puts "Go to this URL: #{authorize_url}"
    Launchy.open(authorize_url)

    puts "Login, and type your verification code in"
    oauth_verifier = gets.chomp
    access_token = request_token.get_access_token(
      :oauth_verifier => oauth_verifier
    )

    # response = access_token
    #   .get("https://api.twitter.com/1.1/statuses/user_timeline.json")
    #   .body

    # access_token
  end

  def self.path_to_url(path, query_values = nil)
    # All Twitter API calls are of the format
    # "https://api.twitter.com/1.1/#{path}.json". Use
    # `Addressable::URI` to build the full URL from just the
    # meaningful part of the path (`statuses/user_timeline`)
    Addressable::URI.new(:scheme => "https", :host => "api.twitter.com", :path => "/1.1/#{path}.json", :query_values => query_values).to_s
  end
end
