# frozen_string_literal: true

module Backend
  module Actions
    module Stays
      class Update < Backend::Action
        include Deps["repos.stay_repo"]

        ATTRS = %i[notes checked_in_at checked_out_at].freeze

        def handle(request, response)
          id = request.params[:id].to_i
          return not_found(response) unless stay_repo.find(id)
          attrs = parsed_body(request).slice(*ATTRS)
          stay = stay_repo.update(id, attrs)
          json(response, stay.to_h)
        rescue => e
          json(response, {error: e.message}, status: 422)
        end
      end
    end
  end
end
