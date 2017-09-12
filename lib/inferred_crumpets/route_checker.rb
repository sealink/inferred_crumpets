module InferredCrumpets
  class RouteChecker
    def initialize(view_context)
      @view_context = view_context
    end

    def linkable?(subject)
      @view_context.url_for(subject) && true
    rescue NoMethodError
      false
    end

    def can_route?(subject, action, params = {})
      @view_context.url_for({
        action:     action,
        controller: subject.class.table_name,
      }.merge(params))
    rescue ActionController::RoutingError
      false
    end
  end
end
