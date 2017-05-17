module InferredCrumpets
  class Builder
    attr_reader :view_context, :subject, :parents

    def self.build_all!(view_context, subject, parents = [])
      new(view_context, subject, parents).build_all!
    end

    def self.build_single!(view_context, subject)
      new(view_context, subject).build_single!
    end

    def initialize(view_context, subject, parents = [])
      @view_context = view_context
      @subject      = subject
      @parents      = parents
    end

    def build_all!
      build_crumb_for_parents!
      build_crumb_for_collection!
      build_crumb_for_action!
    end

    def build_single!
      build_crumb_for_subject!
    end

    private

    def build_crumb_for_parents!
      parents.each do |parent|
        Builder.build_single!(view_context, parent)
      end
    end

    def build_crumb_for_collection!
      if action == 'index'
        Crumpet.crumbs.add_crumb view_context.params[:controller].titleize
      else
        Crumpet.crumbs.add_crumb subject.class.table_name.titleize, url_for_collection
      end
    end

    def build_crumb_for_action!
      case action
      when 'new'
        Crumpet.crumbs.add_crumb 'New', wrapper_options: { class: 'active' }
      when 'edit'
        build_crumb_for_subject!
        Crumpet.crumbs.add_crumb 'Edit', wrapper_options: { class: 'active' }
      when 'index'
        nil
      else
        build_crumb_for_subject!
      end
    end

    def build_crumb_for_subject!
      Crumpet.crumbs.add_crumb(subject_name, url_for_subject)
    end

    def url_for_subject
      return unless can_show?
      view_context.polymorphic_url(subject_with_parents)
    rescue NoMethodError
      subject_becomes!
      view_context.polymorphic_url(subject_with_parents)
    end

    def url_for_collection
      view_context.polymorphic_url(class_with_parents)
    rescue NoMethodError
      subject_becomes!
      view_context.polymorphic_url(class_with_parents)
    end

    def can_show?
      view_context.url_for(
        action:     :show,
        controller: subject.class.table_name,
        id:         subject.id,
      )
    rescue ActionController::RoutingError
      false
    end

    def action
      return 'new' if subject && subject.new_record?
      view_context.params[:action]
    end

    def subject_name
      subject.respond_to?(:name) && subject.name.present? ? subject.name : subject.to_s
    end

    def class_with_parents
      (parents + [subject.class]).compact
    end

    def subject_with_parents
      (parents + [subject]).compact
    end

    def subject_becomes!
      @subject = subject.becomes subject.class.base_class
    end

    def namespaces
      return [] unless view_context.respond_to?(:namespaces)
      Array(view_context.namespaces)
    end

    def inherited_resources?
      defined?(InheritedResources) && view_context.controller.responder == InheritedResources::Responder
    end
  end
end
