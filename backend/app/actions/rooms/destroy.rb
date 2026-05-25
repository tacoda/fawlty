# frozen_string_literal: true

module Backend
  module Actions
    module Rooms
      class Destroy < Backend::Action
        include Deps["repos.room_repo"]

        def handle(request, response)
          id = request.params[:id].to_i
          return not_found(response) unless room_repo.find(id)
          room_repo.delete(id)
          response.status = 204
          response.body = ""
        end
      end
    end
  end
end
