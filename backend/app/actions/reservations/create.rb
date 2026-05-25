# frozen_string_literal: true

module Backend
  module Actions
    module Reservations
      class Create < Backend::Action
        include Deps["repos.reservation_repo"]

        ATTRS = %i[guest_id room_id check_in_date check_out_date status notes].freeze

        def handle(request, response)
          attrs = parsed_body(request).slice(*ATTRS)
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
