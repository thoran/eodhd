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
    # The server's half of the opening handshake (RFC 6455, 4.2.2), answering with the request line.
    def accept_handshake(socket)
      request = []
      request << socket.gets.chomp until request.last == ''
      key = request.grep(/\ASec-WebSocket-Key:/i).first.split(':', 2).last.strip
      accept = [OpenSSL::Digest.digest('SHA1', key + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')].pack('m0')
      socket.write("HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: #{accept}\r\n\r\n")
      request.first
    end

    # A masked client frame of under 126 bytes.
    def read_client_frame(socket)
      length = socket.read(2).bytes.last & 0x7f
      mask = socket.read(4).bytes
      socket.read(length).bytes.each_with_index.map{|byte, i| byte ^ mask[i % 4]}.pack('C*')
    end

    def text_frame(text)
      [0x81, text.bytesize].pack('CC') + text
    end

    def close_frame
      [0x88, 2, 1000].pack('CCn')
    end

    it "subscribes, hands each message to the consumer, and returns once the server closes" do
      received = []
      client = Eodhd::WebSocketClient.new(api_token: 'api_token', asset_class: 'crypto', symbols: 'BTC-USD', consumer: ->(data){received << data})
      client_socket, server_socket = UNIXSocket.pair
      server = Thread.new do
        request_line = accept_handshake(server_socket)
        subscription = read_client_frame(server_socket)
        server_socket.write(text_frame('{"s":"BTC-USD","p":"81430.24"}'))
        server_socket.write(close_frame)
        [request_line, subscription]
      end
      client.stub(:tls_socket, client_socket){client.run}
      request_line, subscription = server.value
      _(request_line).must_equal('GET /ws/crypto?api_token=api_token HTTP/1.1')
      _(JSON.parse(subscription)).must_equal({'action' => 'subscribe', 'symbols' => 'BTC-USD'})
      _(received).must_equal([{'s' => 'BTC-USD', 'p' => '81430.24'}])
    end

    it "returns when the server drops the connection" do
      received = []
      client = Eodhd::WebSocketClient.new(api_token: 'api_token', asset_class: 'crypto', symbols: 'BTC-USD', consumer: ->(data){received << data})
      client_socket, server_socket = UNIXSocket.pair
      server = Thread.new do
        accept_handshake(server_socket)
        server_socket.close
      end
      client.stub(:tls_socket, client_socket){client.run}
      server.join
      _(received).must_equal([])
    end
  end

  describe "#tls_socket" do
    def self_signed_certificate(key)
      certificate = OpenSSL::X509::Certificate.new
      certificate.version = 2
      certificate.serial = 1
      certificate.subject = certificate.issuer = OpenSSL::X509::Name.parse('/CN=localhost')
      certificate.public_key = key.public_key
      certificate.not_before = Time.now - 60
      certificate.not_after = Time.now + 3600
      certificate.sign(key, OpenSSL::Digest.new('SHA256'))
    end

    # Yields the port of a local TLS server with a self-signed certificate, and the host names its clients sent.
    def with_tls_server
      key = OpenSSL::PKey::RSA.new(2048)
      context = OpenSSL::SSL::SSLContext.new
      context.cert, context.key = self_signed_certificate(key), key
      server_names = []
      context.servername_cb = ->((socket, name)){server_names << name; nil}
      tcp_server = TCPServer.new('localhost', 0)
      ssl_server = OpenSSL::SSL::SSLServer.new(tcp_server, context)
      server = Thread.new{ssl_server.accept rescue nil}
      yield tcp_server.addr[1], server_names
    ensure
      server&.join(5)
      ssl_server&.close
    end

    it "names the host in the TLS handshake (SNI)" do
      client = Eodhd::WebSocketClient.new(api_token: api_token, asset_class: 'crypto', symbols: 'BTC-USD', consumer: consumer)
      with_tls_server do |port, server_names|
        _{client.send(:tls_socket, host: 'localhost', port: port)}.must_raise(OpenSSL::SSL::SSLError)
        _(server_names).must_equal(['localhost'])
      end
    end

    it "refuses a certificate it can't verify" do
      client = Eodhd::WebSocketClient.new(api_token: api_token, asset_class: 'crypto', symbols: 'BTC-USD', consumer: consumer)
      with_tls_server do |port, server_names|
        error = _{client.send(:tls_socket, host: 'localhost', port: port)}.must_raise(OpenSSL::SSL::SSLError)
        _(error.message).must_match(/certificate verify failed/)
      end
    end
  end

  describe "Handler" do
    describe "#on_open" do
      it "subscribes to its symbols" do
        sent = []
        driver = Struct.new(:sent){def text(message) = sent << message}.new(sent)
        handler = Eodhd::WebSocketClient::Handler.new(symbols: 'AAPL,MSFT', consumer: consumer, logger: nil)
        handler.on_open(driver)
        _(sent.collect{|message| JSON.parse(message)}).must_equal([{'action' => 'subscribe', 'symbols' => 'AAPL,MSFT'}])
      end
    end

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
