module InferredCrumpets
  module ControllerAdditions
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def infer_crumbs_for(*args)
        options      = args.extract_options!
        parent_names = Array(options.delete(:through) || [])
        subject_name = args.first

        return if subject_name.blank?

        before_action(options) do
          subject = view_context.instance_variable_get("@#{subject_name}")
          parents = parent_names.map{ |parent_name| view_context.instance_variable_get("@#{parent_name}") }
          InferredCrumpets::Builder.new(view_context, subject, parents).build_all!
        end
      end
    end
  end
end
