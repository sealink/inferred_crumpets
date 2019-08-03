module InferredCrumpets
  class Builder
    attr_reader :view_context, :subject, :parents

    def self.build_inferred_crumbs!(view_context)
      subject = SubjectFinder.for_context(view_context)
      return unless subject
      parents = [view_context.parent_object].compact.flatten rescue []
      build_all!(view_context, subject, parents)
    end

    def self.build_all!(view_context, subject, parents = [])
      new(view_context, subject, parents).build_all!
    end

    def self.build_single!(view_context, subject)
      new(view_context, subject).build_single!
    end

    def initialize(view_context, subject, parents = [])
      @route_checker  = RouteChecker.new(view_context)
      @view_context   = view_context
      @subject        = subject
      @parents        = parents
    end

    def build_all!
      build_crumbs_for_parents!
      build_crumb_for_collection!
      build_crumb_for_action!
    end

    def build_single!
      build_crumb_for_subject!
    end

    private

    def build_crumbs_for_parents!
      parents.each do |parent|
        Builder.build_single!(view_context, parent)
      end
    end

    def build_crumb_for_collection!
      return if parents.present? && linkable?

      if subject.is_a?(ActiveRecord::Relation)
        view_context.crumbs.add_crumb subject_name.pluralize.titleize
      elsif subject.is_a?(ActiveRecord::Base)
        view_context.crumbs.add_crumb subject.class.table_name.titleize, url_for_collection
      end
    end

    def build_crumb_for_action!
      return unless subject.is_a?(ActiveRecord::Base)
      crumb = ActionProcessor.for_action(action)
      build_crumb_for_subject! if crumb.has_subject?
      add_crumb(crumb.label) if crumb.label.present?
    end

    def add_crumb(label)
      view_context.crumbs.add_crumb(label, wrapper_options: { class: 'active' })
    end

    def build_crumb_for_subject!
      view_context.crumbs.add_crumb(subject_name, url_for_subject)
    end

    def url_for_subject
      return unless can_route?(:show, id: subject.id) && linkable?
      view_context.url_for(transformed_subject)
    end

    def url_for_collection
      return view_context.objects_path if view_context.objects_path.present?
      return unless can_route?(:index)
      return view_context.url_for(transformed_subject.class) if linkable?
      return view_context.url_for(class_with_parents) if parents_and_class_linkable?
    end

    def subject_requires_transformation?
      subject.respond_to?(:becomes) && !parents_and_subject_linkable?
    end

    def transformed_subject
      subject_requires_transformation? ? subject.becomes(subject.class.base_class) : subject
    end

    def linkable?
      @route_checker.linkable?(transformed_subject)
    end

    def parents_and_subject_linkable?
      @route_checker.linkable?((parents + [subject.class]).compact)
    end

    def parents_and_class_linkable?
      @route_checker.linkable?((parents + [transformed_subject.class]).compact)
    end

    def can_route?(action, params = {})
      @route_checker.can_route?(subject, action, params)
    end

    def action
      view_context.params[:action]
    end

    def subject_name
      subject.respond_to?(:page_title) && subject.page_title.present? ? subject.page_title : subject.to_s
    end

    def class_with_parents
      [parents.last, transformed_subject.class].compact
    end

    def inherited_resources?
      defined?(InheritedResources) && view_context.controller.responder == InheritedResources::Responder
    end
  end
end
