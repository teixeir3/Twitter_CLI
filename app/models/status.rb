require './lib/twitter_session.rb'
require 'open-uri'

def internet_connection?
  begin
    true if open("http://www.google.com/")
  rescue => e
    puts e
    false
  end
end

class Status < ActiveRecord::Base
  attr_accessible :body, :twitter_status_id, :twitter_user_id

  validates :body, :presence => true, :length => { maximum: 139 }
  validates :twitter_status_id, :uniqueness => true, :presence => true
  validates :twitter_user_id, :presence => true

  def self.fetch_by_user_id!(id)
    # uses TwitterSession class to fetch the timeline. Call gets
    # parse_json
    unsaved_statuses = Status.parse_json(TwitterSession.get("statuses/user_timeline", { :user_id => id }))

    saved_status_ids = Status.where(:twitter_user_id => id).pluck(:twitter_status_id)


    new_statuses = []
    unsaved_statuses.each do |status|
      next if saved_status_ids.include?(status.twitter_status_id)

      status.save!
      new_statuses << status
    end

    new_statuses
  end

  def self.parse_json(raw_statuses)
    parsed_statuses = []
    unless raw_statuses.nil?
      raw_statuses.each do |status|
        cur_text = status["text"]
        cur_twitter_status_id = status["id_str"]
        cur_twitter_user_id = status["user"]["id_str"]

        parsed_statuses << Status.new(:body => cur_text, :twitter_status_id => cur_twitter_status_id, :twitter_user_id => cur_twitter_user_id)
      end
    end

    parsed_statuses
  end

  def self.get_by_twitter_user_id(twitter_user_id)
    if internet_connection?
      fetch_by_user_id!!(twitter_user_id)
    end

    where(:twitter_user_id => twitter_user_id)
  end

  def self.post(body)
    status_params = TwitterSession.post(
    "statuses/update",
    { :status => body }
    )

    Status.parse_json([status_params])[0].save!
  end

end
