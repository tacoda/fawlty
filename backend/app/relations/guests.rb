# frozen_string_literal: true

module Backend
  module Relations
    class Guests < Backend::DB::Relation
      schema :guests, infer: true do
        associations do
          has_many :reservations
          has_many :stays
        end
      end
    end
  end
end
