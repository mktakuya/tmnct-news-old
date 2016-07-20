require './lib/tmnct-news'
require 'erb'
require 'yaml'

config = YAML.load(ERB.new(IO.read('./config/config.yml')).result)
TmNCTNews.new(config).run
