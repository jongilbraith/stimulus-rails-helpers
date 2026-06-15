require_relative "stimulus_renderer/attribute_renderers"

module StimulusRailsHelpers
  class StimulusRenderer
    attr_reader :namespace, :view_context

    def initialize(view_context:, namespace: nil)
      @namespace = namespace
      @view_context = view_context
    end

    def element(element = :div, controllers: [], values: {}, outlets: {}, actions: {}, targets: {}, **other_attributes, &block)
      generated_data_attributes = data(controllers:, values:, outlets:, actions:, targets:)
      generated_data_attributes.merge!(other_attributes.delete(:data)) if other_attributes[:data]

      if block_given?
        view_context.content_tag(element, data: generated_data_attributes, **other_attributes, &block)
      else
        view_context.content_tag(element, "", data: generated_data_attributes, **other_attributes)
      end
    end
    alias el element

    def data(controllers: [], values: {}, outlets: {}, actions: {}, targets: {}, **other_data_attributes)
      returned_attributes = {}

      if controllers.present?
        returned_attributes[:controller] = AttributeRenderers::Controllers.new(controllers, namespace:).to_s
      end

      if values.present?
        returned_attributes.merge!(AttributeRenderers::Values.new(values, namespace:).to_h)
      end

      if outlets.present?
        returned_attributes.merge!(AttributeRenderers::Outlets.new(outlets, namespace:).to_h)
      end

      if actions.present?
        returned_attributes[:action] = AttributeRenderers::Actions.new(actions, namespace:).to_s
      end

      if targets.present?
        returned_attributes.merge!(AttributeRenderers::Targets.new(targets, namespace:).to_h)
      end

      returned_attributes.merge(other_data_attributes)
    end
  end
end
