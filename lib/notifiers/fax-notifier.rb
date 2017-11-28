require 'yaml'
require 'twilio-ruby'

class FaxNotifier
  def initialize(news, config)
    @news = news
    @fax_config = config
  end

  def notify
    client = Twilio::REST::Client.new @fax_config['twilio_account_sid'], @fax_config['twilio_auth_token']

    from_number = @fax_config['twilio_from_number'].to_s
    to_number = @fax_config['twilio_to_number'].to_s

    category = @news.category
    post_id = @news.link.split('/')[-1].gsub('.html', '')
    media_url = "https://tmnct-news.mktakuya.net/fax?category=#{category}&post_id=#{post_id}"

    client.fax.v1.faxes.create(
      from: '+81' + from_number,
      to: '+81' + to_number,
      media_url: media_url,
      quality: :standard
    )
  end
end
