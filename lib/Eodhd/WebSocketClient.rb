# Eodhd/WebSocketClient.rb
# Eodhd::WebSocketClient

# Notes:
# 1. All 4 of 4 WebSocket endpoints which Eodhd provides (See https://eodhd.com/financial-apis/new-real-time-data-api-websockets.) are as folllows...
#   i.   US market trade data: wss://ws.eodhistoricaldata.com/ws/us?api_token=XXX
#   ii.  US market quote data: wss://ws.eodhistoricaldata.com/ws/us-quote?api_token=XXX
#   iii. Forex: wss://ws.eodhistoricaldata.com/ws/forex?api_token=XXX
#   iv.  Crypto: wss://ws.eodhistoricaldata.com/ws/crypto?api_token=XXX

require 'iodine'
require 'json'

require_relative './DefaultLogger'
require_relative './Error'

class Eodhd
  class WebSocketClient
    API_HOST = 'ws.eodhistoricaldata.com'

    class Handler
      def on_open(connection)
        connection.write({action: 'subscribe', symbols: @symbols}.to_json)
      end

      def on_message(connection, message)
        dataframe = handle_response(message)
        @consumer.call(dataframe) if @consumer
      end

      def on_close(connection)
        Iodine.stop
      end

      private

      def initialize(symbols:, consumer:, logger: nil)
        @symbols = symbols
        @consumer = consumer
        @logger = logger
      end

      def log_error(code:, message:, body:)
        log_string = "WebSocketError #{code}\n#{message}\n#{body}"
        @logger.error(log_string) if use_logging?
      end

      def handle_response(message)
        JSON.parse(message)
      rescue StandardError => e
        log_error(code: 'ws_parse_error', message: e.message, body: message)
        raise Eodhd::Error.new(code: 'ws_parse_error', message: e.message, body: message)
      end

      def use_logging?
        !@logger.nil?
      end
    end

    class << self
      def path_prefix
        '/ws'
      end

      def us_trade(api_token:, symbols:, consumer:)
        new(api_token: api_token, asset_class: 'us', symbols: symbols, consumer: consumer)
      end
      alias_method :us, :us_trade

      def us_quote(api_token:, symbols:, consumer:)
        new(api_token: api_token, asset_class: 'us-quote', symbols: symbols, consumer: consumer)
      end

      def forex(api_token:, symbols:, consumer:)
        new(api_token: api_token, asset_class: 'forex', symbols: symbols, consumer: consumer)
      end

      def crypto(api_token:, symbols:, consumer:)
        new(api_token: api_token, asset_class: 'crypto', symbols: symbols, consumer: consumer)
      end
    end # class << self

    attr_accessor\
      :api_token,
      :asset_class,
      :consumer,
      :logger

    attr_reader\
      :symbols

    def symbols=(symbols)
      @symbols = format_symbols(symbols)
    end

    def run
      Iodine.threads = 1
      Iodine.connect(url: url, handler: Handler.new(symbols: @symbols, consumer: @consumer, logger: @logger))
      Iodine.start
    rescue SystemExit, Interrupt
      return
    end

    private

    def initialize(api_token:, asset_class:, symbols:, consumer:, logger: nil, use_default_logger: false)
      @api_token = api_token
      @asset_class = asset_class # crypto, forex, us-quote, us
      @symbols = format_symbols(symbols)
      @consumer = consumer
      @logger = use_default_logger ? DefaultLogger.logger : logger
    end

    def use_logging?
      !@logger.nil?
    end

    def format_symbols(symbols)
      if symbols.is_a?(Array)
        symbols.join(',')
      elsif symbols.is_a?(String)
        symbols
      end
    end

    def url
      "wss://#{API_HOST}#{self.class.path_prefix}/#{@asset_class}?api_token=#{@api_token}"
    end
  end
end
