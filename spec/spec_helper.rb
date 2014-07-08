require "rubygems"
require "bundler/setup"

require "rack"
require "rack/test"
require "rspec"

require "sqlite3"
require "sequel"
require "core_data"
require "rack/scaffold"

require "database_cleaner"

# Setup an in-memory database
DB = Sequel.sqlite

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Rack::Test::Methods
  config.color = true

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  def app
    Rack::Lint.new(Rack::Scaffold.new model: './example/Example.xcdatamodeld')
  end

  def check(*args)
  end

end