# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"
require "date"
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

    # Returns [[check_in, check_out], nil] or [nil, message]. The message is
    # written for the clerk staring at the form, not for a log.
    def date_range(check_in, check_out)
      from = parse_date(check_in)
      to = parse_date(check_out)
      return [nil, "Check-in and check-out dates are required."] unless from && to
      return [nil, "Check-out must be after check-in."] unless to > from

      [[from, to], nil]
    end

    def parse_date(value)
      Date.parse(value.to_s)
    rescue Date::Error
      nil
    end
  end
end
