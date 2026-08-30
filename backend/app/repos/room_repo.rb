# frozen_string_literal: true

module Backend
  module Repos
    class RoomRepo < Backend::DB::Repo
      def all
        rooms.order(:number).to_a
      end

      # Rooms nothing else holds over those nights. See
      # Backend::Relations::Reservations#overlapping for what "holds" means.
      def available(check_in_date, check_out_date)
        held = container.relations[:reservations]
          .overlapping(check_in_date, check_out_date)
          .select(:room_id)
          .dataset

        rooms.exclude(id: held).order(:number).to_a
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
