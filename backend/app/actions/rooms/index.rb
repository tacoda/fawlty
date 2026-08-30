# frozen_string_literal: true

module Backend
  module Actions
    module Rooms
      class Index < Backend::Action
        include Deps["repos.room_repo"]

        def handle(request, response)
          check_in = request.params[:check_in_date]
          check_out = request.params[:check_out_date]
          return json(response, room_repo.all.map(&:to_h)) if check_in.nil? && check_out.nil?

          dates = stay_dates(check_in, check_out)
          return json(response, {error: STAY_DATES_ERROR}, status: 422) unless dates

          json(response, room_repo.available(*dates).map(&:to_h))
        end
      end
    end
  end
end
