# frozen_string_literal: true

module Backend
  module Actions
    module Stays
      class Show < Backend::Action
        include Deps["repos.stay_repo"]

        def handle(request, response)
          stay = stay_repo.find(request.params[:id].to_i)
          return not_found(response) unless stay
          json(response, stay.to_h)
        end
      end
    end
  end
end
