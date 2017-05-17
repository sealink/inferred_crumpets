module InferredCrumpets
  class Railtie < Rails::Railtie
    initializer 'inferred_crumpets.setup_action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        self.class_eval do
          include InferredCrumpets::ControllerAdditions
        end
      end
    end
  end
end
