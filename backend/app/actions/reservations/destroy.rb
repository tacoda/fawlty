# frozen_string_literal: true

module Backend
  module Actions
    module Reservations
      class Destroy < Backend::Action
        include Deps["repos.reservation_repo"]

        def handle(request, response)
          id = request.params[:id].to_i
          return not_found(response) unless reservation_repo.find(id)
          reservation_repo.delete(id)
          response.status = 204
          response.body = ""
        end
      end
    end
  end
end
