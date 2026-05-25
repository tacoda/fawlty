# frozen_string_literal: true

module Backend
  module Actions
    module Stays
      class Index < Backend::Action
        include Deps["repos.stay_repo"]

        def handle(request, response)
          scope = request.params[:active] == "true" ? stay_repo.active : stay_repo.all
          json(response, scope.map(&:to_h))
        end
      end
    end
  end
end
