# frozen_string_literal: true

module Backend
  module Actions
    module Guests
      class Index < Backend::Action
        include Deps["repos.guest_repo"]

        def handle(request, response)
          json(response, guest_repo.all.map(&:to_h))
        end
      end
    end
  end
end
