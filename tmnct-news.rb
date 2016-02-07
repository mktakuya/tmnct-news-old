require './lib/tmnct-news'
require 'yaml'

config = YAML.load_file("./config/config.yml")
TmNCTNews.new(config).run
