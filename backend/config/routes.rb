# frozen_string_literal: true

module Backend
  class Routes < Hanami::Routes
    root to: ->(env) { [200, {"content-type" => "application/json"}, [%({"app":"fawlty","status":"ok"})]] }

    get "/health", to: ->(env) { [200, {"content-type" => "application/json"}, [%({"status":"ok"})]] }

    scope "api" do
      # Rooms
      get    "/rooms",       to: "rooms.index"
      post   "/rooms",       to: "rooms.create"
      get    "/rooms/:id",   to: "rooms.show"
      patch  "/rooms/:id",   to: "rooms.update"
      delete "/rooms/:id",   to: "rooms.destroy"

      # Guests
      get    "/guests",      to: "guests.index"
      post   "/guests",      to: "guests.create"
      get    "/guests/:id",  to: "guests.show"
      patch  "/guests/:id",  to: "guests.update"
      delete "/guests/:id",  to: "guests.destroy"

      # Reservations
      get    "/reservations",      to: "reservations.index"
      post   "/reservations",      to: "reservations.create"
      get    "/reservations/:id",  to: "reservations.show"
      patch  "/reservations/:id",  to: "reservations.update"
      delete "/reservations/:id",  to: "reservations.destroy"
      post   "/reservations/:id/check_in", to: "reservations.check_in"

      # Stays
      get    "/stays",            to: "stays.index"
      post   "/stays",            to: "stays.create"
      get    "/stays/:id",        to: "stays.show"
      patch  "/stays/:id",        to: "stays.update"
      post   "/stays/:id/check_out", to: "stays.check_out"
    end
  end
end
