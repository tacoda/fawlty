# frozen_string_literal: true

module Backend
  module Actions
    module Reservations
      class Show < Backend::Action
        include Deps["repos.reservation_repo"]

        def handle(request, response)
          reservation = reservation_repo.find(request.params[:id].to_i)
          return not_found(response) unless reservation
          json(response, reservation.to_h)
        end
      end
    end
  end
end
