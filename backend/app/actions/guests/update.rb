# frozen_string_literal: true

module Backend
  module Actions
    module Guests
      class Update < Backend::Action
        include Deps["repos.guest_repo"]

        ATTRS = %i[first_name last_name email phone address notes].freeze

        def handle(request, response)
          id = request.params[:id].to_i
          return not_found(response) unless guest_repo.find(id)
          attrs = parsed_body(request).slice(*ATTRS)
          guest = guest_repo.update(id, attrs)
          json(response, guest.to_h)
        rescue => e
          json(response, {error: e.message}, status: 422)
        end
      end
    end
  end
end
