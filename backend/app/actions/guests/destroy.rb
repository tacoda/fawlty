# frozen_string_literal: true

module Backend
  module Actions
    module Guests
      class Destroy < Backend::Action
        include Deps["repos.guest_repo"]

        def handle(request, response)
          id = request.params[:id].to_i
          return not_found(response) unless guest_repo.find(id)
          guest_repo.delete(id)
          response.status = 204
          response.body = ""
        end
      end
    end
  end
end
