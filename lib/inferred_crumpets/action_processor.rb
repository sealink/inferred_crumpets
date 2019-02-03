# frozen_string_literal: true

module InferredCrumpets
  class ActionProcessor
    NEW_ACTIONS = %w[new create].freeze
    private_constant :NEW_ACTIONS

    EDIT_ACTIONS = %w[edit update].freeze
    private_constant :EDIT_ACTIONS

    IGNORED_ACTIONS = %w[show].freeze
    private_constant :IGNORED_ACTIONS

    NEW_LABEL = 'New'
    private_constant :NEW_LABEL

    EDIT_LABEL = 'Edit'
    private_constant :EDIT_LABEL

    def self.for_action(action)
      new(action).call
    end

    def initialize(action)
      @action = action
    end

    def call
      return build_opts(nil) if IGNORED_ACTIONS.include?(@action)
      return build_opts(NEW_LABEL, false) if NEW_ACTIONS.include?(@action)
      return build_opts(EDIT_LABEL) if EDIT_ACTIONS.include?(@action)

      build_opts(@action.humanize)
    end

    private

    def build_opts(label, has_subject = true)
      OpenStruct.new(label: label, has_subject?: has_subject)
    end
  end
end
