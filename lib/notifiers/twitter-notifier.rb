require 'twitter'

class TwitterNotifier
  def initialize(news, config)
    @news = news
    @twitter_api_keys = config
  end

  def notify
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = @twitter_api_keys['consumer_key']
      config.consumer_secret = @twitter_api_keys['consumer_secret']
      config.access_token = @twitter_api_keys['access_token']
      config.access_token_secret = @twitter_api_keys['access_token_secret']
    end

    tweet = "#{@news.title}\n"
    tweet << "#{@news.link} #苫小牧高専"

    if @news.img_urls.empty?
      client.update(tweet)
    else
      media_ids = @news.img_urls.map do |img_url|
        client.upload open(img_url)
      end
      client.update(tweet, {media_ids: media_ids.first(4).join(',')})
    end
  end
end

