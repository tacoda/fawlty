# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"
require "json"

module Backend
  class Action < Hanami::Action
    include Dry::Monads[:result]

    private

    def parsed_body(request)
      body = request.body.read
      return {} if body.nil? || body.empty?
      JSON.parse(body, symbolize_names: true)
    rescue JSON::ParserError
      {}
    end

    def json(response, data, status: 200)
      response.status = status
      response.format = :json
      response.body = JSON.generate(data)
    end

    def not_found(response)
      json(response, {error: "not_found"}, status: 404)
    end
  end
end
