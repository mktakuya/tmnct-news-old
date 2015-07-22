require 'open-uri'
require 'nokogiri'
require 'pstore'

class TmNCTNews
  def run
    fetch

    puts @latest_news
    if is_updated?
      puts "updated..."
      save
    else
      puts "not updated..."
    end
  end

  private
  def fetch
    @latest_news = {}
    url = 'http://www2.tomakomai-ct.ac.jp/feed'
    doc = Nokogiri::XML(open(url))
    item = doc.search('item')[0]

    @latest_news[:title] = item.search('title').text
    @latest_news[:link] = item.search('link').text
    @latest_news[:pubdate] = DateTime.parse(item.search('pubDate').text)
    @latest_news[:category] = item.search('category').text
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
    end
  end
end

if $0 == __FILE__
  client = TmNCTNews.new
  client.run
end

