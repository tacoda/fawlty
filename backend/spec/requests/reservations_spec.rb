# frozen_string_literal: true

RSpec.describe "Reservations API", type: :request do
  # Rows are created through the API and given unique room numbers so runs do
  # not collide with each other or with seed data.
  def create_room
    post_json "/api/rooms", {number: "T#{SecureRandom.hex(4)}", room_type: "standard"}
    json_body["id"]
  end

  def create_guest
    post_json "/api/guests", {first_name: "Basil", last_name: "Fawlty"}
    json_body["id"]
  end

  def book(room_id, guest_id, check_in, check_out)
    post_json "/api/reservations", {
      guest_id: guest_id, room_id: room_id,
      check_in_date: check_in, check_out_date: check_out
    }
  end

  let(:room_id) { create_room }
  let(:guest_id) { create_guest }

  describe "POST /api/reservations" do
    it "creates the reservation when the room is free" do
      book(room_id, guest_id, "2031-03-01", "2031-03-05")

      expect(last_response.status).to eq(201)
      expect(json_body["room_id"]).to eq(room_id)
    end

    it "refuses a second booking that covers the same nights" do
      book(room_id, guest_id, "2031-04-01", "2031-04-05")
      book(room_id, guest_id, "2031-04-03", "2031-04-07")

      expect(last_response.status).to eq(409)
      expect(json_body["error"]).to match(/already booked/)
    end

    it "allows a new guest to arrive the day the last one leaves" do
      book(room_id, guest_id, "2031-05-01", "2031-05-08")
      book(room_id, guest_id, "2031-05-08", "2031-05-11")

      expect(last_response.status).to eq(201)
    end

    it "ignores a cancelled reservation when checking for a conflict" do
      book(room_id, guest_id, "2031-06-01", "2031-06-05")
      patch_json "/api/reservations/#{json_body["id"]}", {status: "cancelled"}

      book(room_id, guest_id, "2031-06-01", "2031-06-05")

      expect(last_response.status).to eq(201)
    end

    it "returns 422 rather than 500 for dates that run backwards" do
      book(room_id, guest_id, "2031-07-10", "2031-07-02")

      expect(last_response.status).to eq(422)
      expect(json_body["error"]).to match(/check-out after check-in/)
    end

    it "returns 422 for a missing check-out date" do
      post_json "/api/reservations", {
        guest_id: guest_id, room_id: room_id, check_in_date: "2031-08-01"
      }

      expect(last_response.status).to eq(422)
    end
  end

  describe "GET /api/rooms with dates" do
    it "omits a room another reservation holds over those nights" do
      book(room_id, guest_id, "2031-09-01", "2031-09-05")

      get "/api/rooms?check_in_date=2031-09-02&check_out_date=2031-09-04"

      expect(last_response.status).to eq(200)
      expect(json_body.map { |r| r["id"] }).not_to include(room_id)
    end

    it "offers a room whose current stay ends the morning the next one starts" do
      book(room_id, guest_id, "2031-10-01", "2031-10-08")

      get "/api/rooms?check_in_date=2031-10-08&check_out_date=2031-10-10"

      expect(json_body.map { |r| r["id"] }).to include(room_id)
    end

    it "returns every room when no dates are given" do
      room_id # created up front, so the GET below sees it

      get "/api/rooms"

      expect(last_response.status).to eq(200)
      expect(json_body.map { |r| r["id"] }).to include(room_id)
    end

    it "returns 422 for an unparseable date" do
      get "/api/rooms?check_in_date=not-a-date&check_out_date=2031-11-02"

      expect(last_response.status).to eq(422)
      expect(json_body["error"]).to match(/YYYY-MM-DD/)
    end
  end
end
