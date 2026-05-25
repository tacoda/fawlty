# frozen_string_literal: true

module Backend
  module Repos
    class ReservationRepo < Backend::DB::Repo
      def all
        reservations.order(Sequel.desc(:check_in_date)).to_a
      end

      def find(id)
        reservations.by_pk(id).one
      end

      def create(attrs)
        reservations.changeset(:create, attrs).commit
      end

      def update(id, attrs)
        reservations.by_pk(id).changeset(:update, attrs).commit
      end

      def delete(id)
        reservations.by_pk(id).command(:delete).call
      end

      def set_status(id, status)
        update(id, status: status)
      end
    end
  end
end
