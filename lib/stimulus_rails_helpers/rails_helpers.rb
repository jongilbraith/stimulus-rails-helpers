module StimulusRailsHelpers
  module RailsHelpers
    def stimulus(namespace: nil)
      if namespace.is_a?(Array)
        yield(*namespace.map { |ns| StimulusRenderer.new(namespace: ns, view_context: self) })
      else
        yield StimulusRenderer.new(namespace:, view_context: self)
      end
    end
  end
end
