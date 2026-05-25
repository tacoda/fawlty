# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :guests do
      primary_key :id
      column :first_name, String, null: false
      column :last_name,  String, null: false
      column :email,      String
      column :phone,      String
      column :address,    String, text: true
      column :notes,      String, text: true
      column :created_at, DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at, DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP

      index :email
    end
  end
end
