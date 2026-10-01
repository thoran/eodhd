# eodhd_test.rb

require_relative './helper'

describe Eodhd do
  let(:api_token){ENV.fetch('EODHD_API_TOKEN', '<API_TOKEN>')}
  let(:eodhd){Eodhd.new(api_token: api_token)}

  describe "#exchanges" do
    it "delegates to Eodhd::Exchange.all" do
      VCR.use_cassette('eodhd_exchanges') do
        exchanges = eodhd.exchanges
        _(exchanges).must_be_kind_of(Array)
        _(exchanges).wont_be_empty
        _(exchanges.first).must_be_kind_of(Eodhd::Exchange)
      end
    end
  end

  describe "#exchange_symbols" do
    it "delegates to Eodhd::ExchangeSymbol.all" do
      VCR.use_cassette('eodhd_exchange_symbols') do
        symbols = eodhd.exchange_symbols(exchange_code: 'AU')
        _(symbols).must_be_kind_of(Array)
        _(symbols).wont_be_empty
        _(symbols.first).must_be_kind_of(Eodhd::ExchangeSymbol)
      end
    end
  end

  describe "#eod_data" do
    it "delegates to Eodhd::EodData.all" do
      VCR.use_cassette('eodhd_eod_data') do
        eod_data = eodhd.eod_data(exchange_code: 'AU', symbol: 'BHP', period: 'd')
        _(eod_data).must_be_kind_of(Array)
        _(eod_data).wont_be_empty
        _(eod_data.first).must_be_kind_of(Eodhd::EodData)
      end
    end
  end

  describe "#eod_bulk_last_day" do
    it "delegates to Eodhd::EodBulkLastDay.all" do
      VCR.use_cassette('eodhd_eod_bulk_last_day') do
        bulk_last_day = eodhd.eod_bulk_last_day(exchange_code: 'AU', date: '2024-09-30')
        _(bulk_last_day).must_be_kind_of(Array)
        _(bulk_last_day).wont_be_empty
        _(bulk_last_day.first).must_be_kind_of(Eodhd::EodBulkLastDay)
      end
    end
  end

  describe "#intraday" do
    it "delegates to Eodhd::Intraday.all" do
      VCR.use_cassette('eodhd_intraday') do
        intraday_data = eodhd.intraday(exchange_code: 'US', symbol: 'AAPL', interval: '5m')
        _(intraday_data).must_be_kind_of(Array)
        _(intraday_data).wont_be_empty
        _(intraday_data.first).must_be_kind_of(Eodhd::Intraday)
      end
    end
  end

  describe "#fundamentals" do
    it "delegates to Eodhd::Fundamentals.all" do
      VCR.use_cassette('eodhd_fundamentals') do
        fundamental_data = eodhd.fundamentals(exchange_code: 'US', symbol: 'AAPL')
        _(fundamental_data).must_be_kind_of(Eodhd::Fundamentals)
        _(fundamental_data.general).must_be_kind_of(Eodhd::Fundamentals::General)
      end
    end
  end
end
