# frozen_string_literal: true

module Backend
  module Actions
    module Stays
      class Create < Backend::Action
        include Deps["repos.stay_repo", "repos.room_repo"]

        ATTRS = %i[reservation_id guest_id room_id checked_in_at notes].freeze

        def handle(request, response)
          attrs = parsed_body(request).slice(*ATTRS)
          attrs[:checked_in_at] ||= Time.now
          stay = stay_repo.create(attrs)
          room_repo.set_status(attrs[:room_id], "occupied") if attrs[:room_id]
          json(response, stay.to_h, status: 201)
        rescue => e
          json(response, {error: e.message}, status: 422)
        end
      end
    end
  end
end
