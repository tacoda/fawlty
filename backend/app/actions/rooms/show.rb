# frozen_string_literal: true

module Backend
  module Actions
    module Rooms
      class Show < Backend::Action
        include Deps["repos.room_repo"]

        def handle(request, response)
          room = room_repo.find(request.params[:id].to_i)
          return not_found(response) unless room
          json(response, room.to_h)
        end
      end
    end
  end
end
