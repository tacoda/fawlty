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

      def available(check_in, check_out)
        rooms
          .exclude(id: conflicting(check_in, check_out).select(:room_id).dataset)
          .order(:number)
          .to_a
      end

      def available?(room_id, check_in, check_out)
        conflicting(check_in, check_out).where(room_id: room_id).count.zero?
      end

      private

      # Housekeeping turns a room over on departure morning, so a stay ending on
      # the 8th and one starting on the 8th do not collide. Both ends of the
      # comparison are therefore strict. A cancelled reservation holds nothing.
      def conflicting(check_in, check_out)
        reservations
          .exclude(status: "cancelled")
          .where(Sequel[:check_in_date] < check_out)
          .where(Sequel[:check_out_date] > check_in)
      end
    end
  end
end
