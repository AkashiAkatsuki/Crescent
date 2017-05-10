require 'bundler'
require 'yaml'
require './core.rb'
Bundler.require

class TwitterManager

  def initialize(user)
    @user = user
    yml = YAML.load_file("config/twitter_auth.yml")
    @client_stream = Twitter::Streaming::Client.new do |config|
      config.consumer_key = yml["consumer_key"]
      config.consumer_secret = yml["consumer_secret"]
      config.access_token = yml["access_token"]
      config.access_token_secret = yml["access_token_secret"]
    end
    @client_rest = Twitter::REST::Client.new do |config|
      config.consumer_key = yml["consumer_key"]
      config.consumer_secret = yml["consumer_secret"]
      config.access_token = yml["access_token"]
      config.access_token_secret = yml["access_token_secret"]
    end
    @screen_name = @client_rest.user.screen_name
  end

  def stream_start
    @client_stream.user do |tweet|
      if (tweet.is_a?(Twitter::Tweet)
          && !tweet.retweeted_status
          && tweet.user.screen_name != @screen_name
         )
        if tweet.text.include?("@" + @screen_name)
          p tweet.text
          # reply
          response = @user.response(tweet.text.gsub(Regexp.new( "@" + @screen_name + " "), ""),
                                    name: tweet.user.name,
                                    screen_name: tweet.user.screen_name
                                   )
          @client_rest.update("@" + tweet.user.screen_name + " " + response)
        else
          #timeline
          puts tweet.text
          @user.listen(tweet.text,
                       name: tweet.user.name,
                       screen_name: tweet.user.screen_name
                      )
        end
      end
    end
  end
  
end

kure = Core.new("Kuretsuki")
puts kure.name + " got up."
TwitterManager.new(kure).stream_start
