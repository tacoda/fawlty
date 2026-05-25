# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :reservations do
      primary_key :id
      foreign_key :guest_id, :guests, null: false, on_delete: :restrict
      foreign_key :room_id,  :rooms,  null: false, on_delete: :restrict
      column :check_in_date,  Date, null: false
      column :check_out_date, Date, null: false
      column :status,         String, null: false, default: "booked"
      column :notes,          String, text: true
      column :created_at,     DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at,     DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP

      index :status
      index :check_in_date
    end
  end
end
