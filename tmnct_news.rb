require 'open-uri'
require 'nokogiri'
require 'pstore'
require 'yaml'
require 'twitter'
require 'logger'

class TmNCTNews
  def run
    fetch

    if is_updated?
      save
      tweet
      output_log(true, @latest_news[:title])
    else
      output_log(false)
    end
  end

  private
  def fetch
    @latest_news = {}
    feed_url = 'http://www2.tomakomai-ct.ac.jp/feed'
    feed = Nokogiri::XML(open(feed_url))
    item = feed.search('item')[0]

    @latest_news[:title] = item.search('title').text
    @latest_news[:link] = item.search('link').text
    @latest_news[:pubdate] = DateTime.parse(item.search('pubDate').text)
    @latest_news[:category] = item.search('category').text

    @latest_news[:img_urls] = []
    html = Nokogiri::HTML(open(@latest_news[:link]))
    html.search('#main').search('img').each do |img|
      @latest_news[:img_urls].push(img.attributes['src'].value)
    end
  end

  def is_updated?
    db = PStore.new('./cache/latest.db')
    db.transaction(true) do
      return true if db[:pubdate].nil?
      db[:pubdate] < @latest_news[:pubdate]
    end
  end

  def save
    db = PStore.new('./cache/latest.db')
    db.transaction do
      db[:title] = @latest_news[:title]
      db[:link] = @latest_news[:link]
      db[:pubdate] = @latest_news[:pubdate]
      db[:category] = @latest_news[:category]
      db[:img_urls] = @latest_news[:img_urls]
    end
  end

  def tweet
    twitter_api_keys = YAML.load_file('./config/twitter_api_keys.yml')
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = twitter_api_keys['consumer_key']
      config.consumer_secret = twitter_api_keys['consumer_secret']
      config.access_token = twitter_api_keys['access_token']
      config.access_token_secret = twitter_api_keys['access_token_secret']
    end

    tweet = "#{@latest_news[:title]}\n"
    tweet << "#{@latest_news[:link]} #苫小牧高専\n"

    if @latest_news[:img_urls].empty?
      client.update(tweet)
    else
      media_ids = @latest_news[:img_urls].map do |img_url|
        client.upload open(img_url)
      end

      client.update(tweet, {media_ids: media_ids.first(4).join(',')})
    end
  end

  def output_log(updated, title = nil)
    logger = Logger.new('./log/logfile.log')

    if updated
      logger.info("Updated! Title: #{title}")
    else
      logger.info('Not Updated...')
    end
  end
end

if $0 == __FILE__
  client = TmNCTNews.new
  client.run
end

