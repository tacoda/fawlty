# frozen_string_literal: true

RSpec.describe "Rooms API", type: :request do
  describe "GET /api/rooms" do
    it "returns a JSON array" do
      get "/api/rooms"

      expect(last_response.status).to eq(200)
      expect(json_body).to be_an(Array)
    end
  end

  describe "GET /api/rooms/:id" do
    it "returns 404 for a room that does not exist" do
      get "/api/rooms/999999"

      expect(last_response.status).to eq(404)
      expect(json_body).to eq("error" => "not_found")
    end
  end
end
