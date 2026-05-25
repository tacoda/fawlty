# frozen_string_literal: true

module Backend
  module Actions
    module Reservations
      class CheckIn < Backend::Action
        include Deps[
          "repos.reservation_repo",
          "repos.stay_repo",
          "repos.room_repo"
        ]

        def handle(request, response)
          id = request.params[:id].to_i
          reservation = reservation_repo.find(id)
          return not_found(response) unless reservation

          if reservation.status == "checked_in"
            return json(response, {error: "already_checked_in"}, status: 422)
          end

          stay = stay_repo.create(
            reservation_id: reservation.id,
            guest_id: reservation.guest_id,
            room_id: reservation.room_id,
            checked_in_at: Time.now
          )
          reservation_repo.set_status(reservation.id, "checked_in")
          room_repo.set_status(reservation.room_id, "occupied")

          json(response, stay.to_h, status: 201)
        rescue => e
          json(response, {error: e.message}, status: 422)
        end
      end
    end
  end
end
