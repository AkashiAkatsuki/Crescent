# coding: utf-8
require 'bundler'
require 'yaml'
require 'uri'
require './core.rb'
require './dictionary.rb'

class TwitterManager

  def initialize(core)
    @core = core
    yml = YAML.load_file("config/twitter_auth.yml")
    @client_stream = Twitter::Streaming::Client.new(yml)
    @client_rest = Twitter::REST::Client.new(yml)
    @screen_name = @client_rest.user.screen_name
    @config = YAML.load_file("config/twitter.yml")
  end
  
  def stream_start
    today = Time.now.mday
    logger = Logger.new('Logfile')
    followback
    begin
      @client_stream.filter(follow: friend_ids_joined) do |tweet|
        if today != Time.now.mday
          @core.forget_old_words
          followback
          today = Time.now.mday
        end
        if (tweet.is_a?(Twitter::Tweet) && !tweet.retweeted_status && tweet.user.screen_name != @screen_name)
          if tweet.text.include?("@" + @screen_name)
            #reply
            next if @config['bot_friends'].include?(tweet.user.screen_name) && @config['bot_ignore'] > Random.new.rand(1.0)
            search_new_words
            response = @core.response(format_text(tweet.text),
                                      member: tweet.user.name,
                                      screen_name: tweet.user.screen_name)
            @client_rest.update("@" + tweet.user.screen_name + " " + response,
                                in_reply_to_status_id: tweet.id)
          else
            #timeline
            @core.listen(format_text(tweet.text),
                         member: tweet.user.name,
                         screen_name: tweet.user.screen_name)
            search_new_words
            speak = @core.speak
            @client_rest.update(speak) if speak
          end
        end
      end
    rescue => e
      logger.info tweet if defined? tweet
      logger.error e
      @client_rest.update("もう無理… " + e.message)
    end
  end
  
  private
  def followback
    screen_names = Array.new
      @client_rest.followers(count: 200).each do |user|
        begin
          @client_rest.follow user.screen_name unless user.following?
          screen_names.push user.screen_name
          Friend.find_or_create_by(screen_name: user.screen_name) do |f|
            f.name = user.name
            f.love = 0.5
          end
        rescue Twitter::Error::NotFound => e
        end
      end
    if unfollowed = Friend.where.not(screen_name: screen_names)
      unfollowed.delete_all
    end
  end
  
  def format_text(text)
    text.gsub(Regexp.new("(\s|^)@[0-9a-zA-Z_]*"), "").gsub(URI.regexp, "").gsub(Regexp.new("#[0-9a-zA-Z_\-]+"), "")
  end

  def search_new_words
    search_words = @core.new_words
    search_words.each do |w|
      Thread.new do
        @client_rest.search(w + " exclude:retweets lang:ja",
                            result_type: "popular",
                            locale: "ja",
                            count: @config['search_amount']).each do |search|
          @core.search(format_text(search.text))
        end
      end
    end
    @core.clear_new_words
  end

  def friend_ids_joined
    @client_rest.friend_ids.attrs[:ids].join(",")
  end
  
end
