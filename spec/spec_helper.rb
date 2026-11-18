# frozen_string_literal: true

require 'edtf'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!

  # Run in random order to surface order dependencies; reproduce a failing
  # order with --seed
  config.order = :random
  Kernel.srand config.seed

  # edtf 5 has its own types (e.g. EDTF::List) instead of extending Ruby's
  # Date. Examples tagged :edtf5 run with edtf 5 only, :edtf4_or_earlier with
  # edtf 3 and 4 only
  config.filter_run_excluding(defined?(EDTF::List) ? :edtf4_or_earlier : :edtf5)
end
