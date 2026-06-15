module StimulusRailsHelpers
  class Railtie < Rails::Railtie
    initializer "stimulus_rails_helpers.action_view" do
      ActiveSupport.on_load(:action_view) do
        include StimulusRailsHelpers::RailsHelpers
      end
    end
  end
end
