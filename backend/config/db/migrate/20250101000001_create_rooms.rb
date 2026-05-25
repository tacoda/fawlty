# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :rooms do
      primary_key :id
      column :number, String, null: false, unique: true
      column :room_type, String, null: false, default: "standard"
      column :floor, Integer
      column :status, String, null: false, default: "available"
      column :nightly_rate_cents, Integer, null: false, default: 0
      column :notes, String, text: true
      column :created_at, DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at, DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
