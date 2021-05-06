# frozen_string_literal: true
module Hyrax
  module Actors
    ##
    # An actor that registers a work with the HIRMEOS service
    # This actor should come after the model actor which saves the work
    #
    # @example use in middleware
    #   stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
    #     # middleware.use OtherMiddleware
    #     middleware.use Hyrax::Actors::HirmeosActor
    #     # middleware.use MoreMiddleware
    #   end
    #
    #   env = Hyrax::Actors::Environment.new(object, ability, attributes)
    #   last_actor = Hyrax::Actors::Terminator.new
    #   stack.build(last_actor).create(env)
    class HirmeosActor < AbstractActor
      ##
      # @return [Boolean]
      #
      # @see Hyrax::Actors::AbstractActor
      def create(env)
        # Assume the model actor has already run and saved the work
        next_actor.create(env) && register_work_in_hirmeos(env.curation_concern)
      end

      private

      def register_work_in_hirmeos(resource)
        Hyrax::Hirmeos::HirmeosRegistrationJob.perform_later(resource.id)
      end
    end
  end
end
