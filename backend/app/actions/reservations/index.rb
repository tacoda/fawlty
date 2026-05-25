# frozen_string_literal: true

module Backend
  module Actions
    module Reservations
      class Index < Backend::Action
        include Deps["repos.reservation_repo"]

        def handle(request, response)
          json(response, reservation_repo.all.map(&:to_h))
        end
      end
    end
  end
end
