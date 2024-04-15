# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false  # Disable if using Database Cleaner for more control
  config.render_views = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods
  config.include RequestHelpers, type: :request
  # Database Cleaner Configuration
  #config.before(:suite) do
   # DatabaseCleaner.clean_with(:truncation)  # Clean database at the beginning of the test suite
 # end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction  # Use transaction strategy for each example
  end

  config.around(:each) do |example|
   # DatabaseCleaner.cleaning do  # This ensures each test is run with a clean slate
    #  example.run
   # end
  end
end
