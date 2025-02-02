# Eodhd/EodData.rb
# Eodhd::EodData

class Eodhd
  class EodData
    class << self
      def all(client: nil, api_token: nil, exchange_code:, symbol:, period: 'd', from: nil, to: nil)
        load(client: client, api_token: api_token, exchange_code: exchange_code, symbol: symbol, period: period, from: from, to: to)
      end

      private

      def load(client: nil, api_token: nil, exchange_code:, symbol:, period:, from:, to:)
        client ||= Client.new(api_token: api_token)
        client.eod_data(exchange_id: exchange_code, symbol: symbol, period: period, from: from, to: to).collect do |eod_data|
          self.new(
            exchange_code: eod_data['exchange_code'],
            symbol: eod_data['symbol'],
            date: eod_data['date'],
            open: eod_data['open'],
            high: eod_data['high'],
            low: eod_data['low'],
            close: eod_data['close'],
            adjusted_close: eod_data['adjusted_close'],
            volume: eod_data['volume']
          )
        end
      end
    end # class << self

    attr_reader\
      :exchange_code,
      :symbol,
      :date,
      :open,
      :high,
      :low,
      :close,
      :adjusted_close,
      :volume

    def initialize(exchange_code:, symbol:, date:, open:, high:, low:, close:, adjusted_close:, volume:)
      @exchange_code = exchange_code
      @symbol = symbol
      @date = date
      @open = open
      @high = high
      @low = low
      @close = close
      @adjusted_close = adjusted_close
      @volume = volume
    end
  end
end
