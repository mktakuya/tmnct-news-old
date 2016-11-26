require 'twilio-ruby'

class TwilioNotifier
  def initialize(news, config)
    @news = news
    @twilio_config = config
  end

  def notify
    client = Twilio::REST::Client.new @twilio_config['account_sid'], @twilio_config['auth_token']
    url = @twilio_config['twiml_url'] + "?title=#{@news.title}"
    client.account.calls.create(
      from: @twilio_config['from_number'],
      to: @twilio_config['to_number'],
      url: URI.escape(url),
      method: 'get'
    )
  end
end
