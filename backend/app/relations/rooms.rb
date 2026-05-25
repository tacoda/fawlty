# frozen_string_literal: true

module Backend
  module Relations
    class Rooms < Backend::DB::Relation
      schema :rooms, infer: true do
        associations do
          has_many :reservations
          has_many :stays
        end
      end
    end
  end
end
