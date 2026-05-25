# frozen_string_literal: true

module Backend
  module Actions
    module Rooms
      class Update < Backend::Action
        include Deps["repos.room_repo"]

        def handle(request, response)
          id = request.params[:id].to_i
          return not_found(response) unless room_repo.find(id)
          attrs = parsed_body(request).slice(:number, :room_type, :floor, :status, :nightly_rate_cents, :notes)
          room = room_repo.update(id, attrs)
          json(response, room.to_h)
        rescue => e
          json(response, {error: e.message}, status: 422)
        end
      end
    end
  end
end
