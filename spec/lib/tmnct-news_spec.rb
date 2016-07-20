require 'spec_helper'
require 'tmnct-news'
require 'yaml'

describe 'TmNCTNews' do
  let(:config) { YAML.load_file("./config/config.yml.example") }
  before { @client = TmNCTNews.new(config) }

  describe '#initialize' do
    subject { @client }
    it { is_expected.to be_a(TmNCTNews) }
  end

  describe '#run' do
  end

  describe '#load_notifiers' do
    let(:notifiers) do
      config['notifications'].keys.map do |notification|
        Object.const_get(notification.capitalize + 'Notifier')
      end
    end

    it 'populates an array of notifiers' do
      @client.load_notifiers
      expect(@client.notifiers).to match_array(notifiers)
    end
  end

  describe '#fetch' do
    let(:news) { @client.fetch }
    subject { news }

    it { is_expected.to be_a TmNCTNews::News }

    its(:title) { is_expected.to be_a_kind_of(String) }
    its(:link) { is_expected.to be_a_kind_of(String) }
    its(:pubdate) { is_expected.to be_a_kind_of(Time) }
    its(:category) { is_expected.to be_a_kind_of(String) }
    its(:img_urls) { is_expected.to be_a_kind_of(Array) }
    its(:body) { is_expected.to be_a_kind_of(String) }
  end

  describe '#is_updated?' do
  end

  describe '#save' do
  end

  describe '#notify' do
  end
end
