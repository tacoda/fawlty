# frozen_string_literal: true

module Backend
  module Actions
    module Rooms
      class Index < Backend::Action
        include Deps["repos.room_repo"]

        def handle(request, response)
          check_in = request.params[:check_in]
          check_out = request.params[:check_out]
          return json(response, room_repo.all.map(&:to_h)) unless check_in || check_out

          range, message = date_range(check_in, check_out)
          return json(response, {error: message}, status: 422) unless range

          json(response, room_repo.available(*range).map(&:to_h))
        end
      end
    end
  end
end
