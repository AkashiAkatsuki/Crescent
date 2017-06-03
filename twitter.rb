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
    @client_stream.user do |tweet|
      if (tweet.is_a?(Twitter::Tweet) && !tweet.retweeted_status && tweet.user.screen_name != @screen_name)
        if tweet.text.include?("@" + @screen_name)
          p format_text(tweet.text)
          # reply
          response = @user.response(format_text(tweet.text),
                                    name: tweet.user.name,
                                    screen_name: tweet.user.screen_name)
          @client_rest.update("@" + tweet.user.screen_name + " " + response,
                              in_reply_to_status_id: tweet.id)
        else
          #timeline
          puts format_text(tweet.text)
          @user.listen(format_text(tweet.text),
                       name: tweet.user.name,
                       screen_name: tweet.user.screen_name)
        end
      end
    end
  end

  private
  def format_text(text)
    text.gsub(Regexp.new("(\s|^)(@|http|#).*?(\s|$)"), "")
  end
  
end

core = Core.new
puts core.name + " got up."
TwitterManager.new(core).stream_start
