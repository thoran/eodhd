# eodhd.rb

## Description

Access the eodhd.com API with Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
  gem 'eodhd.rb'
```

And then execute:

```bash
  $ bundle
```

Or install it yourself as:

```bash
  $ gem install eodhd.rb
```

## Usage

### Setup

```ruby
api_token = 'api_token'
eodhd = Eodhd.new(api_token: api_token)
```

### List of Exchanges

```ruby
eodhd.exchanges
```

### List of Exchange Symbols

```ruby
exchange = eodhd.exchanges.first

eodhd.exchange_symbols(exchange: exchange)
# OR
eodhd.exchange_symbols(exchange_code: exchange.code)
```

### Retrieve EOD Data For One Symbol

```ruby
exchange = eodhd.exchanges.first
exchange_symbol = eodhd.exchange_symbols(exchange: exchange).first

eodhd.eod_data(exchange: exchange, exchange_symbol: exchange_symbol)
# OR
eodhd.eod_data(exchange_code: exchange.code, exchange_symbol: exchange_symbol)
# OR
eodhd.eod_data(exchange: exchange, symbol: exchange_symbol.code)
# OR
eodhd.eod_data(exchange_code: exchange.code, symbol: exchange_symbol.code)
```

### Retrieve EOD Data For Multiple Symbols For One Date

```ruby
exchange = eodhd.exchanges.first

eodhd.eod_bulk_last_day(exchange: exchange, date: Date.today)
# OR
eodhd.eod_bulk_last_day(exchange_code: exchange.code, date: Date.today)
```

### Retrieve Intraday Data

```ruby
eodhd.intraday(symbol: 'AAPL', exchange_code: 'US', interval: '5m')
# OR with date range (from and to are Unix timestamps)
eodhd.intraday(symbol: 'AAPL', exchange_code: 'US', interval: '1h', from: 1696118400, to: 1696550400)
```

### Retrieve Fundamental Data

```ruby
fd = eodhd.fundamentals(exchange_code: 'US', symbol: 'AAPL')

fd.general
fd.general.name
fd.general.sector
fd.general.industry

fd.highlights
fd.highlights.market_capitalization
fd.highlights.pe_ratio
fd.highlights.dividend_yield
fd.highlights.earnings_share

fd.valuation
fd.valuation.trailing_pe
fd.valuation.forward_pe
fd.valuation.price_book_mrq

fd.shares_stats
fd.shares_stats.shares_outstanding
fd.shares_stats.shares_float

fd.financials
fd.financials.income_statement
fd.financials.income_statement.quarterly
fd.financials.income_statement.yearly
fd.financials.balance_sheet.quarterly
fd.financials.cash_flow.quarterly

fd.earnings
fd.earnings.history
fd.earnings.trend
fd.earnings.annual
```

#### Use the filter parameter to request only specific sections

```ruby
eodhd.fundamentals(exchange_code: 'US', symbol: 'AAPL', filter: 'General')
eodhd.fundamentals(exchange_code: 'US', symbol: 'AAPL', filter: 'Financials::Income_Statement::quarterly')
```

### WebSockets

#### Streaming requires a callable consumer (a proc, lambda, or any object responding to `call`) to handle incoming data frames

```ruby
consumer = ->(data){puts data}
eodhd = Eodhd.new(api_token: api_token, consumer: consumer)

eodhd.us_trade_stream('AAPL,MSFT')
eodhd.us_quote_stream('AAPL,MSFT')
eodhd.forex_stream('EURUSD')
eodhd.crypto_stream('BTC-USD')
```

#### Or use the general interface

```ruby
eodhd.stream(asset_class: 'us', symbols: 'AAPL,MSFT')
```

## License

MIT License. See LICENSE file for details.

## Contributing

1. Fork it ( https://github.com/thoran/eodhd/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request
