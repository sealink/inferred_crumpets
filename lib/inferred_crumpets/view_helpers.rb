module InferredCrumpets
  module ViewHelpers
    def render_inferred_crumbs(options = {})
      InferredCrumpets::Builder.build_inferred_crumbs!(self)
      render_crumbs(options)
    end
  end
end
