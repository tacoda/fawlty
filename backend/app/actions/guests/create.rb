# frozen_string_literal: true

module Backend
  module Actions
    module Guests
      class Create < Backend::Action
        include Deps["repos.guest_repo"]

        ATTRS = %i[first_name last_name email phone address notes].freeze

        def handle(request, response)
          attrs = parsed_body(request).slice(*ATTRS)
          guest = guest_repo.create(attrs)
          json(response, guest.to_h, status: 201)
        rescue => e
          json(response, {error: e.message}, status: 422)
        end
      end
    end
  end
end
