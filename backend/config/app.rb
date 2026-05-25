# frozen_string_literal: true

require "hanami"
require "rack/cors"

module Backend
  class App < Hanami::App
    config.middleware.use Rack::Cors do
      allow do
        origins ENV.fetch("CORS_ORIGINS", "http://localhost:5173").split(",")
        resource "*",
                 headers: :any,
                 methods: [:get, :post, :put, :patch, :delete, :options, :head],
                 expose: ["Content-Type"]
      end
    end

    config.actions.format :json
    config.actions.default_response_format :json
  end
end
