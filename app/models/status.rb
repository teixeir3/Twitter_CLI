require './lib/twitter_session.rb'

class Status < ActiveRecord::Base
  # attr_accessible :title, :body
  validates :body, :presence => true, :length => { maximum: 139 }
  validates :twitter_status_id, :uniqueness => true, :presence => true
  validates :twitter_user_id, :uniqueness => true, :presence => true

  def self.fetch_by_user_id!(id)
    # uses TwitterSession class to fetch the timeline. Call gets
    # parse_json
    TwitterSession.get("statuses/user_timeline", { :user_id => id })

  end

  def self.parse_json

  end

end
