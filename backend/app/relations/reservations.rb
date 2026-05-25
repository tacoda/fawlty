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
    end
  end
end
