module Datadog
  module Contrib
    module ActiveSupport
      # For subscribing and tracing ActiveRecord::Notifications
      module Notifications
        module_function

        def subscribe(pattern, subscriber)
          ::ActiveSupport::Notifications.subscribe(pattern, subscriber)
        end

        def subscriber(span_name, options = {}, tracer = Datadog.tracer, &block)
          Subscriber.new(span_name, options, tracer, &block)
        end

        def subscriber!(pattern, span_name, options = {}, tracer = Datadog.tracer, &block)
          subscriber(span_name, options, tracer, &block).tap do |subscriber|
            subscribe(pattern, subscriber)
          end
        end

        # Represents a single subscriber/tracer for an ActiveSupport::Notification
        class Subscriber
          def initialize(span_name, options, tracer, &block)
            @span_name = span_name
            @options = options
            @tracer = tracer
            @block = block
          end

          def start(_name, _id, _payload)
            @tracer.trace(@span_name, @options)
          end

          def finish(name, id, payload)
            span = @tracer.active_span

            # The subscriber block needs to remember to set the name of the span.
            @block.call(span, name, id, payload)

            span.finish
          end
        end
      end
    end
  end
end
