# frozen_string_literal: true

module Backend
  module Repos
    class RoomRepo < Backend::DB::Repo
      def all
        rooms.order(:number).to_a
      end

      def find(id)
        rooms.by_pk(id).one
      end

      def create(attrs)
        rooms.changeset(:create, attrs).commit
      end

      def update(id, attrs)
        rooms.by_pk(id).changeset(:update, attrs).commit
      end

      def delete(id)
        rooms.by_pk(id).command(:delete).call
      end

      def set_status(id, status)
        update(id, status: status)
      end
    end
  end
end
