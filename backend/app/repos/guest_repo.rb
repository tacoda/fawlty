# frozen_string_literal: true

module Backend
  module Repos
    class GuestRepo < Backend::DB::Repo
      def all
        guests.order(:last_name, :first_name).to_a
      end

      def find(id)
        guests.by_pk(id).one
      end

      def create(attrs)
        guests.changeset(:create, attrs).commit
      end

      def update(id, attrs)
        guests.by_pk(id).changeset(:update, attrs).commit
      end

      def delete(id)
        guests.by_pk(id).command(:delete).call
      end
    end
  end
end
