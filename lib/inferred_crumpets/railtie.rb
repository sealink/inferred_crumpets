module InferredCrumpets
  class Railtie < Rails::Railtie
    initializer 'inferred_crumpets.setup_action_view' do |app|
      ActiveSupport.on_load :action_view do
        self.class_eval do
          include InferredCrumpets::ViewHelpers
        end
      end
    end
  end
end
