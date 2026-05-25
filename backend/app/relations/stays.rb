# frozen_string_literal: true

module Backend
  module Relations
    class Stays < Backend::DB::Relation
      schema :stays, infer: true do
        associations do
          belongs_to :guest
          belongs_to :room
          belongs_to :reservation
        end
      end
    end
  end
end
