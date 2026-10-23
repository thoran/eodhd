# Eodhd/WebSocketClient_test.rb

require_relative '../helper'

describe Eodhd::WebSocketClient do
  let(:api_token){ENV.fetch('EODHD_API_TOKEN', '<API_TOKEN>')}
  let(:consumer){->(data){}}

  describe ".us_trade" do
    it "makes a client for the US trade stream" do
      client = Eodhd::WebSocketClient.us_trade(api_token: api_token, symbols: 'AAPL', consumer: consumer)
      _(client).must_be_instance_of(Eodhd::WebSocketClient)
      _(client.asset_class).must_equal('us')
    end
  end

  describe ".us" do
    it "makes a client for the US trade stream" do
      client = Eodhd::WebSocketClient.us(api_token: api_token, symbols: 'AAPL', consumer: consumer)
      _(client).must_be_instance_of(Eodhd::WebSocketClient)
      _(client.asset_class).must_equal('us')
    end
  end

  describe ".us_quote" do
    it "makes a client for the US quote stream" do
      client = Eodhd::WebSocketClient.us_quote(api_token: api_token, symbols: 'AAPL', consumer: consumer)
      _(client).must_be_instance_of(Eodhd::WebSocketClient)
      _(client.asset_class).must_equal('us-quote')
    end
  end

  describe ".forex" do
    it "makes a client for the forex stream" do
      client = Eodhd::WebSocketClient.forex(api_token: api_token, symbols: 'EURUSD', consumer: consumer)
      _(client).must_be_instance_of(Eodhd::WebSocketClient)
      _(client.asset_class).must_equal('forex')
    end
  end

  describe ".crypto" do
    it "makes a client for the crypto stream" do
      client = Eodhd::WebSocketClient.crypto(api_token: api_token, symbols: 'BTC-USD', consumer: consumer)
      _(client).must_be_instance_of(Eodhd::WebSocketClient)
      _(client.asset_class).must_equal('crypto')
    end
  end

  describe "#initialize" do
    it "accepts array of symbols and formats to comma-separated string" do
      client = Eodhd::WebSocketClient.new(api_token: api_token, asset_class: 'us', symbols: ['AAPL', 'MSFT'], consumer: consumer)
      _(client.symbols).must_equal('AAPL,MSFT')
    end

    it "accepts string of symbols" do
      client = Eodhd::WebSocketClient.new(api_token: api_token, asset_class: 'us', symbols: 'AAPL,MSFT', consumer: consumer)
      _(client.symbols).must_equal('AAPL,MSFT')
    end
  end

  describe "#url" do
    it "generates correct URL for US trade stream" do
      client = Eodhd::WebSocketClient.new(api_token: api_token, asset_class: 'us', symbols: 'AAPL', consumer: consumer)
      _(client.send(:url)).must_equal("wss://ws.eodhistoricaldata.com/ws/us?api_token=#{api_token}")
    end

    it "generates correct URL for US quote stream" do
      client = Eodhd::WebSocketClient.new(api_token: api_token, asset_class: 'us-quote', symbols: 'AAPL', consumer: consumer)
      _(client.send(:url)).must_equal("wss://ws.eodhistoricaldata.com/ws/us-quote?api_token=#{api_token}")
    end

    it "generates correct URL for forex stream" do
      client = Eodhd::WebSocketClient.new(api_token: api_token, asset_class: 'forex', symbols: 'EURUSD', consumer: consumer)
      _(client.send(:url)).must_equal("wss://ws.eodhistoricaldata.com/ws/forex?api_token=#{api_token}")
    end

    it "generates correct URL for crypto stream" do
      client = Eodhd::WebSocketClient.new(api_token: api_token, asset_class: 'crypto', symbols: 'BTC-USD', consumer: consumer)
      _(client.send(:url)).must_equal("wss://ws.eodhistoricaldata.com/ws/crypto?api_token=#{api_token}")
    end
  end

  describe "#format_symbols" do
    it "converts array to comma-separated string" do
      client = Eodhd::WebSocketClient.new(api_token: api_token, asset_class: 'us', symbols: ['AAPL', 'MSFT', 'GOOGL'], consumer: consumer)
      _(client.symbols).must_equal('AAPL,MSFT,GOOGL')
    end

    it "returns string as-is" do
      client = Eodhd::WebSocketClient.new(api_token: api_token, asset_class: 'us', symbols: 'AAPL,MSFT', consumer: consumer)
      _(client.symbols).must_equal('AAPL,MSFT')
    end
  end

  describe "#run" do
    it "configures Iodine and starts connection" do
      client = Eodhd::WebSocketClient.new(api_token: api_token, asset_class: 'us', symbols: 'AAPL', consumer: consumer)

      iodine_connect_called = false
      iodine_start_called = false

      Iodine.stub(:threads=, nil) do
        Iodine.stub(:connect, ->(opts){iodine_connect_called = true}) do
          Iodine.stub(:start, ->{iodine_start_called = true}) do
            client.run
          end
        end
      end

      _(iodine_connect_called).must_equal(true)
      _(iodine_start_called).must_equal(true)
    end
  end

  describe "Handler" do
    describe "#on_message" do
      it "parses JSON and calls consumer" do
        received_data = nil
        test_consumer = ->(data){received_data = data}
        handler = Eodhd::WebSocketClient::Handler.new(symbols: 'AAPL', consumer: test_consumer, logger: nil)

        message = '{"symbol":"AAPL","price":150.0}'
        handler.on_message(nil, message)

        _(received_data).must_be_kind_of(Hash)
        _(received_data['symbol']).must_equal('AAPL')
        _(received_data['price']).must_equal(150.0)
      end

      it "raises Eodhd::Error on invalid JSON" do
        test_consumer = ->(data){}
        handler = Eodhd::WebSocketClient::Handler.new(symbols: 'AAPL', consumer: test_consumer, logger: nil)

        invalid_message = '{invalid json'
        _{handler.on_message(nil, invalid_message)}.must_raise(Eodhd::Error)
      end
    end
  end
end
