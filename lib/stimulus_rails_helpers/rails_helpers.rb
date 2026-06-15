module StimulusRailsHelpers
  module RailsHelpers
    def stimulus_namespace(*namespaces)
      yield(*namespaces.map { |ns| StimulusRenderer.new(namespace: ns, view_context: self) })
    end
    alias stim_ns stimulus_namespace

    def stimulus_element(element = :div, namespace: nil, controllers: [], values: {}, outlets: {}, actions: {}, targets: {}, **other_attributes, &block)
      StimulusRenderer.new(namespace:, view_context: self).element(element, controllers:, values:, outlets:, actions:, targets:, **other_attributes, &block)
    end
    alias stim_el stimulus_element

    def stimulus_data(namespace: nil, controllers: [], values: {}, outlets: {}, actions: {}, targets: {}, **other_data_attributes)
      StimulusRenderer.new(namespace:, view_context: self).data(controllers:, values:, outlets:, actions:, targets:, **other_data_attributes)
    end
    alias stim_data stimulus_data
  end
end
