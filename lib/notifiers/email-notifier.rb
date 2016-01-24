require 'yaml'
require 'pony'

class EmailNotifier
  def initialize(news, config)
    @news = news
    @config = config
  end

  def notify
    if @news.category == "news"
      body = @news.body + "\n"
      body << @news.link + "\n"
    else @news.category == "info"
      body = @news.title + "\n"
      body << @news.link + "\n"
    end

    to_addresses = YAML.load_file('./config/to_addresses.yml')
    to_addresses['to_addresses'].to_a.each do |to_address|
      Pony.mail(
        to: to_address,
        subject: "[苫小牧高専News] #{@news.title}",
        body: body,
        charset: 'utf-8',
        via: :smtp,
        via_options: {
          enable_starttls_auto: @config['server']['enable_starttls_auto'],
          address: @config['server']['address'],
          port: @config['server']['port'],
          user_name: @config['server']['user_name'],
          password: @config['server']['password'],
          authentication: @config['server']['authentication'],
          domain: @config['server']['domain']
        }
      )
    end
  end
end

