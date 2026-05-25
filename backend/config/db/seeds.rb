# frozen_string_literal: true

rooms = Hanami.app["relations.rooms"]
guests = Hanami.app["relations.guests"]

if rooms.count.zero?
  [
    {number: "101", room_type: "standard", floor: 1, status: "available", nightly_rate_cents: 12000},
    {number: "102", room_type: "standard", floor: 1, status: "available", nightly_rate_cents: 12000},
    {number: "201", room_type: "deluxe",   floor: 2, status: "available", nightly_rate_cents: 18000},
    {number: "202", room_type: "deluxe",   floor: 2, status: "cleaning",  nightly_rate_cents: 18000},
    {number: "301", room_type: "suite",    floor: 3, status: "available", nightly_rate_cents: 32000}
  ].each { |r| rooms.changeset(:create, r).commit }
end

if guests.count.zero?
  [
    {first_name: "Basil",  last_name: "Fawlty",  email: "basil@fawlty.example",  phone: "555-0100"},
    {first_name: "Sybil",  last_name: "Fawlty",  email: "sybil@fawlty.example",  phone: "555-0101"},
    {first_name: "Manuel", last_name: "Sanchez", email: "manuel@fawlty.example", phone: "555-0102"}
  ].each { |g| guests.changeset(:create, g).commit }
end
