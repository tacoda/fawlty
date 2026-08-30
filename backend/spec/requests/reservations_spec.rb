# frozen_string_literal: true

RSpec.describe "Reservations API", type: :request do
  let(:db) { Hanami.app["relations.rooms"].dataset.db }
  let(:guest) { Hanami.app["repos.guest_repo"].create(first_name: "Basil", last_name: "Fawlty") }
  let(:room) { Hanami.app["repos.room_repo"].create(number: "201") }
  let(:other_room) { Hanami.app["repos.room_repo"].create(number: "202") }

  before { db.run("TRUNCATE stays, reservations, rooms, guests RESTART IDENTITY CASCADE") }

  def book(room_id, check_in, check_out, status: "booked")
    post_json "/api/reservations", {
      guest_id: guest.id, room_id: room_id, status: status,
      check_in_date: check_in, check_out_date: check_out
    }
  end

  describe "POST /api/reservations" do
    it "books a free room" do
      book(room.id, "2026-03-05", "2026-03-08")

      expect(last_response.status).to eq(201)
      expect(json_body["room_id"]).to eq(room.id)
    end

    it "refuses a room already booked for overlapping nights" do
      book(room.id, "2026-03-05", "2026-03-08")
      book(room.id, "2026-03-07", "2026-03-10")

      expect(last_response.status).to eq(422)
      expect(json_body["error"]).to eq("That room is already booked for those dates.")
    end

    it "allows an arrival on the day the previous guest leaves" do
      book(room.id, "2026-03-05", "2026-03-08")
      book(room.id, "2026-03-08", "2026-03-10")

      expect(last_response.status).to eq(201)
    end

    it "ignores a cancelled reservation when checking the dates" do
      book(room.id, "2026-03-05", "2026-03-08")
      patch_json "/api/reservations/#{json_body["id"]}", {status: "cancelled"}
      book(room.id, "2026-03-05", "2026-03-08")

      expect(last_response.status).to eq(201)
    end

    it "leaves other rooms alone" do
      book(room.id, "2026-03-05", "2026-03-08")
      book(other_room.id, "2026-03-05", "2026-03-08")

      expect(last_response.status).to eq(201)
    end

    it "rejects a missing date instead of raising" do
      post_json "/api/reservations", {guest_id: guest.id, room_id: room.id}

      expect(last_response.status).to eq(422)
      expect(json_body["error"]).to eq("Check-in and check-out dates are required.")
    end

    it "rejects a check-out before the check-in" do
      book(room.id, "2026-03-10", "2026-03-05")

      expect(last_response.status).to eq(422)
      expect(json_body["error"]).to eq("Check-out must be after check-in.")
    end

    it "rejects a date it cannot parse" do
      book(room.id, "not-a-date", "2026-03-05")

      expect(last_response.status).to eq(422)
      expect(json_body["error"]).to eq("Check-in and check-out dates are required.")
    end
  end

  describe "GET /api/rooms with dates" do
    it "omits a room booked across those nights" do
      room and other_room
      book(room.id, "2026-03-05", "2026-03-08")

      get "/api/rooms?check_in=2026-03-06&check_out=2026-03-07"

      expect(last_response.status).to eq(200)
      expect(json_body.map { |r| r["number"] }).to eq(["202"])
    end

    it "offers the room back on turnover day" do
      book(room.id, "2026-03-05", "2026-03-08")

      get "/api/rooms?check_in=2026-03-08&check_out=2026-03-09"

      expect(json_body.map { |r| r["number"] }).to include("201")
    end

    it "offers the room back once the reservation is cancelled" do
      book(room.id, "2026-03-05", "2026-03-08")
      patch_json "/api/reservations/#{json_body["id"]}", {status: "cancelled"}

      get "/api/rooms?check_in=2026-03-05&check_out=2026-03-08"

      expect(json_body.map { |r| r["number"] }).to include("201")
    end

    it "returns every room when no dates are given" do
      room and other_room

      get "/api/rooms"

      expect(json_body.length).to eq(2)
    end

    it "rejects a backwards range" do
      get "/api/rooms?check_in=2026-03-10&check_out=2026-03-05"

      expect(last_response.status).to eq(422)
      expect(json_body["error"]).to eq("Check-out must be after check-in.")
    end

    it "rejects a half-given range" do
      get "/api/rooms?check_in=2026-03-10"

      expect(last_response.status).to eq(422)
      expect(json_body["error"]).to eq("Check-in and check-out dates are required.")
    end
  end
end
