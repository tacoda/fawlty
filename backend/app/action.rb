# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"
require "date"
require "json"

module Backend
  class Action < Hanami::Action
    include Dry::Monads[:result]

    STAY_DATES_ERROR = "check_in_date and check_out_date must be dates in YYYY-MM-DD form, " \
                       "with check-out after check-in"

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

    # The two dates that bound a stay, or nil if they are unusable. Callers turn
    # the nil into a 422 with STAY_DATES_ERROR rather than letting a bad param
    # reach the database.
    def stay_dates(check_in, check_out)
      from = parse_date(check_in)
      to = parse_date(check_out)
      return nil unless from && to && to > from
      [from, to]
    end

    def parse_date(value)
      return value if value.is_a?(Date)
      parts = value.is_a?(String) ? Date._iso8601(value) : nil
      return nil unless parts && parts[:year] && parts[:mon] && parts[:mday]
      return nil unless Date.valid_date?(parts[:year], parts[:mon], parts[:mday])
      Date.new(parts[:year], parts[:mon], parts[:mday])
    end
  end
end
