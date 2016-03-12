require 'yaml'
require 'sendgrid-ruby'

class EmailNotifier
  def initialize(news, config)
    @news = news
    @email_config = config
  end

  def notify
    client = SendGrid::Client.new(api_key: @email_config["sendgrid_api_key"])

    to_addresses = YAML.load_file('./config/to_addresses.yml')
    header = Smtpapi::Header.new
    header.add_to(to_addresses)

    if @news.category == "news"
      text_body = @news.body + "\n"
      text_body << @news.link + "\n"
    else @news.category == "info"
      text_body = @news.title + "\n"
      text_body << @news.link + "\n"
    end

    html_body = text_body.split.map { |p|
      if p.include?("http://")
        "<p><a href=\"#{p}\">#{p}</a></p>"
      else
        "<p>#{p}</p>"
      end
    }.join

    mail = SendGrid::Mail.new do |m|
      m.to = @email_config["from"]
      m.from = @email_config["from"]
      m.from_name = @email_config["from_name"]
      m.subject = "[苫小牧高専News] #{@news.title}"
      m.text = text_body
      m.html = html_body
      m.smtpapi = header
    end
    client.send(mail)
  end
end
