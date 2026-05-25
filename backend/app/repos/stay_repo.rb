# frozen_string_literal: true

module Backend
  module Repos
    class StayRepo < Backend::DB::Repo
      def all
        stays.order(Sequel.desc(:checked_in_at)).to_a
      end

      def active
        stays.where(checked_out_at: nil).to_a
      end

      def find(id)
        stays.by_pk(id).one
      end

      def create(attrs)
        stays.changeset(:create, attrs).commit
      end

      def update(id, attrs)
        stays.by_pk(id).changeset(:update, attrs).commit
      end

      def check_out(id, at: Time.now)
        update(id, checked_out_at: at)
      end
    end
  end
end
