module InferredCrumpets
  class SubjectFinder
    def self.for_context(context)
      new(context).call
    end

    def initialize(context)
      @context = context
    end

    def call
      current_object = begin @context.current_object rescue nil end
      collection_object = begin @context.collection rescue nil end
      current_object || collection_object
    end
  end
end
