# eodhd.rb
# Eodhd

require_relative './Eodhd/Client'
require_relative './Eodhd/EodBulkLastDay'
require_relative './Eodhd/EodData'
require_relative './Eodhd/Exchange'
require_relative './Eodhd/ExchangeSymbol'
require_relative './Eodhd/Intraday'
require_relative './Eodhd/Fundamentals'
require_relative './Eodhd/WebSocketClient'
require_relative './Eodhd/VERSION'

class Eodhd
  def exchanges
    Eodhd::Exchange.all(api_token: @api_token)
  end

  def exchange_symbols(exchange: nil, exchange_code: nil)
    exchange_code ||= exchange&.code
    Eodhd::ExchangeSymbol.all(api_token: @api_token, exchange_code: exchange_code)
  end

  def eod_data(exchange: nil, exchange_code: nil, exchange_symbol: nil, symbol: nil, period: nil, from: nil, to: nil)
    exchange_code ||= exchange&.code
    symbol ||= exchange_symbol&.code
    Eodhd::EodData.all(api_token: @api_token, exchange_code: exchange_code, symbol: symbol, period: period, from: from, to: to)
  end

  def eod_bulk_last_day(exchange: nil, exchange_code: nil, date:)
    exchange_code ||= exchange&.code
    Eodhd::EodBulkLastDay.all(api_token: @api_token, exchange_code: exchange_code, date: date)
  end

  def intraday(exchange: nil, exchange_code: nil, exchange_symbol: nil, symbol: nil, interval:, from: nil, to: nil)
    exchange_code ||= exchange&.code
    symbol ||= exchange_symbol&.code
    Eodhd::Intraday.all(api_token: @api_token, exchange_code: exchange_code, symbol: symbol, interval: interval, from: from, to: to)
  end

  def fundamentals(exchange: nil, exchange_code: nil, exchange_symbol: nil, symbol: nil, filter: nil)
    exchange_code ||= exchange&.code
    symbol ||= exchange_symbol&.code
    Eodhd::Fundamentals.all(api_token: @api_token, exchange_code: exchange_code, symbol: symbol, filter: filter)
  end

  def us_trade_stream(symbols)
    stream(asset_class: 'us', symbols: symbols)
  end
  alias_method :us_stream, :us_trade_stream

  def us_quote_stream(symbols)
    stream(asset_class: 'us-quote', symbols: symbols)
  end

  def forex_stream(symbols)
    stream(asset_class: 'forex', symbols: symbols)
  end

  def crypto_stream(symbols)
    stream(asset_class: 'crypto', symbols: symbols)
  end

  private

  def initialize(api_token:, consumer: nil)
    @api_token = api_token
    @consumer = consumer
  end

  def web_socket(asset_class:, symbols:)
    Eodhd::WebSocketClient.new(api_token: @api_token, asset_class: asset_class, symbols: symbols, consumer: @consumer)
  end

  def stream(asset_class:, symbols:)
    web_socket(asset_class: asset_class, symbols: symbols).run
  end
end
