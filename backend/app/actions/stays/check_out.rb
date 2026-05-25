# frozen_string_literal: true

module Backend
  module Actions
    module Stays
      class CheckOut < Backend::Action
        include Deps[
          "repos.stay_repo",
          "repos.room_repo",
          "repos.reservation_repo"
        ]

        def handle(request, response)
          id = request.params[:id].to_i
          stay = stay_repo.find(id)
          return not_found(response) unless stay
          if stay.checked_out_at
            return json(response, {error: "already_checked_out"}, status: 422)
          end

          updated = stay_repo.check_out(id, at: Time.now)
          room_repo.set_status(stay.room_id, "cleaning")
          reservation_repo.set_status(stay.reservation_id, "checked_out") if stay.reservation_id

          json(response, updated.to_h)
        rescue => e
          json(response, {error: e.message}, status: 422)
        end
      end
    end
  end
end
