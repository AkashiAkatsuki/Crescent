# coding: utf-8
require 'bundler'
require 'yaml'
require './core.rb'
Bundler.require

class TwitterManager

  def initialize(user)
    @user = user
    yml = YAML.load_file("config/twitter_auth.yml")
    @client_stream = Twitter::Streaming::Client.new(yml)
    @client_rest = Twitter::REST::Client.new(yml)
    @screen_name = @client_rest.user.screen_name
  end

  def stream_start
    begin
      @client_stream.user do |tweet|
        if (tweet.is_a?(Twitter::Tweet) && !tweet.retweeted_status && tweet.user.screen_name != @screen_name)
          if tweet.text.include?("@" + @screen_name)
            #reply
            response = @user.response(format_text(tweet.text),
                                      member: tweet.user.screen_name)
            @client_rest.update("@" + tweet.user.screen_name + " " + response,
                                in_reply_to_status_id: tweet.id)
          else
          #timeline
            puts format_text(tweet.text)
            search_words = @user.listen(format_text(tweet.text),
                                        member: tweet.user.screen_name)
            search_words.each do |w|
              Thread.new do
              @client_rest.search(w + " exclude:retweets",
                                  result_type: "popular",
                                  locale: "ja").first(10).each do |search|
                @user.listen(format_text(search.text))
              end
              end
            end
          speak = @user.speak
          @client_rest.update(speak) if speak 
          end
        end
      end
    rescue => e 
      @client_rest.update("もう無理… " + e.message)
      p e
    end
  end
  
  private
  def format_text(text)
    text.gsub(Regexp.new("(\s|^)(@|http|#).*?(\s|$)x"), "")
  end
  
end

core = Core.new
puts core.name + " got up."
TwitterManager.new(core).stream_start
