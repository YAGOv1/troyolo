# tweets.rb
# ------------------------------------------------------------------------------
# The MIT License (MIT)
# 
# Copyright (c) 2013 James Ross
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# ------------------------------------------------------------------------------
file_dir = File.expand_path File.dirname(__FILE__)
frutils = File.expand_path File.join(file_dir, '..', 'deps', 'frutils.git')

require File.join frutils, 'log.rb'
require 'rubygems'
require 'twitter'

module Troyolo

# TODO Configure Twitter API and each Client separately, figure out why none
# of the clients authenticate...

class Tweets
  attr_reader :username
  
public
  #----------------------------------------------------------------------------
  def initialize(client_config = {})
    @username = client_config[:username]
    @log = FlyingRobots::Log.new({
      :name => "Tweets[#{@username}]",
      #:volume => FlyingRobots::Log::VOLUME_DEBUG
    })
    @client = _create_twitter_client client_config
    @token = @client.token
  end

  #----------------------------------------------------------------------------
  def search(query, start_id)
    @log.info "Searching for tweets '#{query}', since tweet #{start_id}"
    results = Twitter.search(
      query,
      :count => MAX_SEARCH_RESULTS,
      :result_type => "recent",
      :since_id => start_id
    )
    @log.info "Found #{results.statuses.count} tweets"
    @log.info "Last tweet id found: #{results.max_id}"
    results
  end

  #----------------------------------------------------------------------------
  def tweet(message)
    @log.info "Tweeting '#{message}'"
    @client.update(message)
  end

  #----------------------------------------------------------------------------
  def reply(to_tweet, username, response)
    @log.info "Responding to tweet '#{to_tweet}"
    @client.update(
      "@#{username} #{response}}", 
      :in_reply_to_status_id => to_tweet
    )
  end

  #----------------------------------------------------------------------------
  def followers_count
    @client.followers_count
  end

  #----------------------------------------------------------------------------
  def follower_ids(username)
    Twitter.follower_ids(username)
  end

private
  #----------------------------------------------------------------------------
  def _create_twitter_client(config)
    @log.debug "Creating new twitter client with config: ", config
    Twitter::Client.new(
      :oauth_token => config[:oauth_token],
      :oauth_token_secret => config[:oauth_secret],
      :endpoint => config[:authorize_url]
    )
  end
end

end
