module InferredCrumpets
  module ControllerAdditions
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def infer_crumbs_for(*args)
        options = args.extract_options!
        parents = Array(options.delete(:through) || [])
        subject = args.first

        return if subject.blank?

        before_action(options) do
          parents.map!{ |parent| instance_variable_get("@#{parent}") }
          parents.compact!

          parents.each do |parent|
            name = parent.class.model_name.human.pluralize
            url  = polymorphic_path(parent.class) rescue nil
            add_crumb(name, url)

            name = parent.to_s
            url  = polymorphic_path(parent) rescue nil
            add_crumb(name, url)
          end

          subjects      = instance_variable_get("@#{subject}s")
          subject       = instance_variable_get("@#{subject}")
          subject_class = subject.try(:class) || subjects.try(:model)

          if subject_class
            name = subject_class.model_name.human.pluralize
            url  = polymorphic_path(parents.map(&:class) << subject_class) rescue nil
            add_crumb(name, url)
          end

          if subject
            name = subject.to_s
            url  = polymorphic_path(parents << subject) rescue nil
            add_crumb(name, url)
          end
        end
      end
    end
  end
end
