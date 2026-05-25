# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :stays do
      primary_key :id
      foreign_key :reservation_id, :reservations, null: true,  on_delete: :set_null
      foreign_key :guest_id,       :guests,       null: false, on_delete: :restrict
      foreign_key :room_id,        :rooms,        null: false, on_delete: :restrict
      column :checked_in_at,  DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :checked_out_at, DateTime
      column :notes,          String, text: true
      column :created_at,     DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at,     DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP

      index :checked_out_at
    end
  end
end
