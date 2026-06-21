module StimulusRailsHelpers
  class StimulusRenderer
    module AttributeRenderers
      class Base
        include ActionView::Helpers::OutputSafetyHelper

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
          # Have to consider escaping due to action notation containing `->`
          safe_join(to_a, " ")
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
            # Have to consider escaping due to action notation containing `->`
            "#{prefix}#{kebabize(controller_name)}##{descriptor.to_s.camelize(:lower)}".html_safe

          # actions: { controller: { event: :action } }
          elsif descriptor.is_a?(Hash)
            dom_event = descriptor.keys.first
            stimulus_function = descriptor.values.first

            # Have to consider escaping due to action notation containing `->`
            "#{dom_event}->#{parse_action_names(controller_name, stimulus_function)}".html_safe

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
