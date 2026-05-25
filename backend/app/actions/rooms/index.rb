# frozen_string_literal: true

module Backend
  module Actions
    module Rooms
      class Index < Backend::Action
        include Deps["repos.room_repo"]

        def handle(request, response)
          json(response, room_repo.all.map(&:to_h))
        end
      end
    end
  end
end
