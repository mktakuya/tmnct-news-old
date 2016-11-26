require 'logger'
require 'date'
require 'open-uri'
require 'nokogiri'
require 'pstore'

LOGGER = Logger.new("./log/#{Date.today.to_s}.log")

class TmNCTNews
  attr_reader :notifiers

  def initialize(config)
    @config = config
    @cached_news = PStore.new('./cache/latest.db')
    @latest_news = News.new
    @notifiers = []
  end

  def run
    @latest_news = fetch
    if is_updated?
      LOGGER.info("Updated!! Title: #{@latest_news.title} URL: #{@latest_news.link}")
      save
      load_notifiers
      notify
    else
      LOGGER.info("None")
    end
  end

  def load_notifiers
    lib_dir = File.dirname(__FILE__)
    full_pattern = File.join(lib_dir, 'notifiers', '*.rb')
    Dir.glob(full_pattern).each { |file| require file }

    @config["notifications"].each_key do |key|
      notifier_class = self.class.const_get(key.capitalize + "Notifier")
      @notifiers << notifier_class.new(@latest_news, @config["notifications"][key])
    end
  end

  def fetch
    feed = Nokogiri::XML(open(@config["feed_url"]))
    item = feed.search('item')[0]

    @latest_news.title = item.search('title').text
    @latest_news.link = item.search('link').text
    @latest_news.pubdate = Time.parse(item.search('pubDate').text)
    @latest_news.category = item.search('category').text
    @latest_news.img_urls = []

    html = Nokogiri::HTML(open(@latest_news.link))
    html.search('#main').search('img').each do |img|
      @latest_news.img_urls.push(img.attributes['src'].value)
    end
    @latest_news.body = html.search('.inner')[1].search('p').text.delete("　").squeeze("\n")

    @latest_news
  end

  def is_updated?
    @cached_news.transaction(true) do
      return true if @cached_news[:pubdate].nil?
      @cached_news[:pubdate] < @latest_news.pubdate
    end
  end

  def save
    db = PStore.new('./cache/latest.db')
    db.transaction do
      db[:title] = @latest_news.title
      db[:link] = @latest_news.link
      db[:pubdate] = @latest_news.pubdate
      db[:category] = @latest_news.category
      db[:body] = @latest_news.body
      db[:img_urls] = @latest_news.img_urls
    end
  end

  def notify
    @notifiers.each do |notifier|
      begin
        notifier.notify
      rescue
        LOGGER.error("An error occurred on #{notifier.to_s}")
      end
    end
  end

  News = Struct.new("News", :title, :link, :pubdate, :category, :img_urls, :body)
end
