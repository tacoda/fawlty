# frozen_string_literal: true

module Backend
  module Actions
    module Rooms
      class Create < Backend::Action
        include Deps["repos.room_repo"]

        def handle(request, response)
          attrs = parsed_body(request).slice(:number, :room_type, :floor, :status, :nightly_rate_cents, :notes)
          room = room_repo.create(attrs)
          json(response, room.to_h, status: 201)
        rescue => e
          json(response, {error: e.message}, status: 422)
        end
      end
    end
  end
end
