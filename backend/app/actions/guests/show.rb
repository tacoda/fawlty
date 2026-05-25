# frozen_string_literal: true

module Backend
  module Actions
    module Guests
      class Show < Backend::Action
        include Deps["repos.guest_repo"]

        def handle(request, response)
          guest = guest_repo.find(request.params[:id].to_i)
          return not_found(response) unless guest
          json(response, guest.to_h)
        end
      end
    end
  end
end
