# frozen_string_literal: true

module Backend
  module Relations
    class Reservations < Backend::DB::Relation
      schema :reservations, infer: true do
        associations do
          belongs_to :guest
          belongs_to :room
          has_many :stays
        end
      end

      # Reservations that hold a room over the given nights. Half-open on
      # purpose: housekeeping turns a room over the morning a guest leaves, so a
      # reservation ending on the 8th does not block one starting on the 8th.
      # A cancelled reservation holds nothing.
      def overlapping(check_in_date, check_out_date)
        exclude(status: "cancelled")
          .where(
            (Sequel[:check_in_date] < check_out_date) &
            (Sequel[:check_out_date] > check_in_date)
          )
      end
    end
  end
end
