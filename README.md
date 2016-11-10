# 苫小牧高専ニュースBot
## 概要
苫小牧高専のニュースを http://www.tomakomai-ct.ac.jp/feed/ から拾ってきて、Twitterやメールで通知するBot。

## 使い方
### 設定ファイルを用意する

```
$ cp config/config.yml.example config/config.yml
$ cp config/to_addresses.yml.example config/to_addresses.yml
```

configやto_addressesを編集。

### cronに登録する

crontabなどを使って登録する。

## 通知方法を追加したい時
例として、slack通知を追加したいとする。

### config/config.yml に 通知用の設定を追加する。
```
notifications:
  slack:
    webhook_url: "YOUR_WEBHOOK_URL"
    channnel: "#YOUR_CHANNEL"
```

### lib/notifiers以下にslack-notifier.rbを設置し、SlackNotifierクラスを定義する。コンストラクタには、config.ymlに書いた値が渡される。
```
class SlackNotifier
  def initialize(config)
    # Setup your notifier class
  end

  def notify
    # notify
  end
end
```
### あとは TmNCTNews#notify から呼び出される

```
class TmNCTNews
  # 省略...
  def load_notifiers
    lib_dir = File.dirname(__FILE__)
    full_pattern = File.join(lib_dir, 'notifiers', '*.rb')
    Dir.glob(full_pattern).each { |file| require file }

    @config["notifications"].each_key do |key|
      notifier_class = self.class.const_get(key.capitalize + "Notifier")
      @notifiers << notifier_class.new(@latest_news, @config["notifications"][key])
    end
  end

  # 省略...

  def notify
    @notifiers.each { |notifier| notifier.notify }
  end

  # 省略...
end
```

