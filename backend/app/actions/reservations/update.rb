# frozen_string_literal: true

module Backend
  module Actions
    module Reservations
      class Update < Backend::Action
        include Deps["repos.reservation_repo"]

        ATTRS = %i[guest_id room_id check_in_date check_out_date status notes].freeze

        def handle(request, response)
          id = request.params[:id].to_i
          return not_found(response) unless reservation_repo.find(id)
          attrs = parsed_body(request).slice(*ATTRS)
          reservation = reservation_repo.update(id, attrs)
          json(response, reservation.to_h)
        rescue => e
          json(response, {error: e.message}, status: 422)
        end
      end
    end
  end
end
