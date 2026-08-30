# frozen_string_literal: true

ENV["HANAMI_ENV"] ||= "test"

require "hanami/prepare"
require "rack/test"
require "json"
require "securerandom"

module RequestHelpers
  include Rack::Test::Methods

  def app = Hanami.app

  def json_body = JSON.parse(last_response.body)

  def post_json(path, payload)
    post path, JSON.generate(payload), {"CONTENT_TYPE" => "application/json"}
  end

  def patch_json(path, payload)
    patch path, JSON.generate(payload), {"CONTENT_TYPE" => "application/json"}
  end
end

RSpec.configure do |config|
  config.expect_with(:rspec) { |e| e.syntax = :expect }
  config.disable_monkey_patching!
  config.filter_run_when_matching :focus
  config.include RequestHelpers, type: :request
end
