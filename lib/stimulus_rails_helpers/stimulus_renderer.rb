module StimulusRailsHelpers
  class StimulusRenderer
    attr_reader :namespace, :view_context

    def initialize(view_context:, namespace: nil)
      @namespace = namespace
      @view_context = view_context
    end

    def element(element = :div, controllers: [], values: {}, outlets: {}, actions: {}, targets: {}, **other_attributes, &block)
      generated_data_attributes = data_attributes(controllers:, values:, outlets:, actions:, targets:)
      generated_data_attributes.merge!(other_attributes.delete(:data)) if other_attributes[:data]

      if block_given?
        view_context.content_tag(element, data: generated_data_attributes, **other_attributes, &block)
      else
        view_context.content_tag(element, "", data: generated_data_attributes, **other_attributes)
      end
    end

    def data_attributes(controllers: [], values: {}, outlets: {}, actions: {}, targets: {}, **other_data_attributes)
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

    module AttributeRenderers
      class Base
        attr_reader :descriptors, :namespace

        def initialize(descriptors, namespace: [])
          @descriptors = descriptors
          @namespace = namespace
        end

        private

        def prefix
          @prefix ||= namespace.present? ? parse_namespace(namespace) : ""
        end

        def parse_namespace(namespace)
          if namespace.is_a?(String) || namespace.is_a?(Symbol)
            kebabize(namespace.to_s) + "--"
          elsif namespace.is_a?(Array)
            namespace.map { |name| parse_namespace(name) }.join
          elsif namespace.is_a?(Hash)
            namespace.map { |name, children| parse_namespace(name) + parse_namespace(children) }.join
          end
        end

        def kebabize(string_or_symbol)
          string_or_symbol.to_s.underscore.tr("_", "-")
        end
      end

      class Controllers < Base
        def to_s
          Array(descriptors).map { |controller_name| "#{prefix}#{kebabize(controller_name)}" }.join(" ")
        end
      end

      class Values < Base
        def to_h
          {}.tap do |out|
            descriptors.each do |controller, values|
              values.each do |value_name, value_value|
                out["#{prefix}#{kebabize(controller)}-#{kebabize(value_name)}-value"] = value_value
              end
            end
          end
        end
      end

      class Outlets < Base
        def to_h
          {}.tap do |out|
            descriptors.each do |controller, outlets|
              outlets.each do |target_controller, outlet_selector|
                out["#{prefix}#{kebabize(controller)}-#{prefix}#{kebabize(target_controller)}-outlet"] = outlet_selector
              end
            end
          end
        end
      end

      class Actions < Base
        def to_s
          to_a.join(" ")
        end

        def to_a
          [].tap do |out|
            descriptors.each do |controller, action_descriptor|
              Array(parse_action_names(controller, action_descriptor)).each { |el| out << el }
            end
          end
        end

        private

        # Note that this can return a string, or array of strings
        def parse_action_names(controller_name, descriptor)
          # actions: { controller: :action }
          if descriptor.is_a?(String) || descriptor.is_a?(Symbol)
            "#{prefix}#{kebabize(controller_name)}##{descriptor.to_s.camelize(:lower)}"

          # actions: { controller: { event: :action } }
          elsif descriptor.is_a?(Hash)
            dom_event = descriptor.keys.first
            stimulus_function = descriptor.values.first

            "#{dom_event}->#{parse_action_names(controller_name, stimulus_function)}"

          # actions: { controller: [:action, { event: :action }] }
          elsif descriptor.is_a?(Array)
            descriptor.map { |element| parse_action_names(controller_name, element) }
          end
        end
      end

      class Targets < Base
        def to_h
          {}.tap do |out|
            descriptors.each do |controller, target_name|
              out["#{prefix}#{kebabize(controller)}-target"] = target_name.to_s.camelize(:lower)
            end
          end
        end
      end
    end
  end
end
