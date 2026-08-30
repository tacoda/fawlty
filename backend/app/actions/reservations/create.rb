# frozen_string_literal: true

module Backend
  module Actions
    module Reservations
      class Create < Backend::Action
        include Deps["repos.reservation_repo", "repos.room_repo"]

        ATTRS = %i[guest_id room_id check_in_date check_out_date status notes].freeze

        def handle(request, response)
          attrs = parsed_body(request).slice(*ATTRS)
          range, message = date_range(attrs[:check_in_date], attrs[:check_out_date])
          return json(response, {error: message}, status: 422) unless range

          unless room_repo.available?(attrs[:room_id], *range)
            return json(response, {error: "That room is already booked for those dates."}, status: 422)
          end

          attrs[:status] ||= "booked"
          reservation = reservation_repo.create(attrs)
          json(response, reservation.to_h, status: 201)
        rescue => e
          json(response, {error: e.message}, status: 422)
        end
      end
    end
  end
end
