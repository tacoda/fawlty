# frozen_string_literal: true

module Backend
  module Actions
    module Reservations
      class Create < Backend::Action
        include Deps["repos.reservation_repo"]

        ATTRS = %i[guest_id room_id check_in_date check_out_date status notes].freeze

        CONFLICT_ERROR = "that room is already booked for those nights"

        def handle(request, response)
          attrs = parsed_body(request).slice(*ATTRS)
          attrs[:status] ||= "booked"

          dates = stay_dates(attrs[:check_in_date], attrs[:check_out_date])
          return json(response, {error: STAY_DATES_ERROR}, status: 422) unless dates

          if reservation_repo.double_booked?(attrs[:room_id], *dates)
            return json(response, {error: CONFLICT_ERROR}, status: 409)
          end

          reservation = reservation_repo.create(attrs)
          json(response, reservation.to_h, status: 201)
        rescue => e
          json(response, {error: e.message}, status: 422)
        end
      end
    end
  end
end
