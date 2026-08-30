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

      # True when another live reservation already holds that room over those
      # nights, which is the double-booking the front desk used to discover at
      # check-in.
      def double_booked?(room_id, check_in_date, check_out_date)
        reservations
          .overlapping(check_in_date, check_out_date)
          .where(room_id: room_id)
          .count
          .positive?
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
