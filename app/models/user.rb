require 'twitter_session'

class User < ActiveRecord::Base
  attr_accessible :twitter_user_id, :screen_name

  has_many(
    :statuses,
    :class_name => 'Status',
    :foreign_key => :twitter_user_id,
    :primary_key => :twitter_user_id
  )

  validates(:twitter_user_id, :screen_name, :presence => true)

  def fetch_by_screen_name!(screen_name)
    user = User.find_by_screen_name(screen_name)


    user = User.fetch_by_screen_name!(screen_name) if user.nil?

    user
  end

  def self.parse_twitter_user(twitter_user_params)

    User.new(:screen_name => twitter_user_params["screen_name"], :twitter_user_id => twitter_user_params["id_str"])
  end

  def fetch_statuses!
    Status.fetch_by_twitter_user_id!(self.twitter_user_id)
  end
end
