module Bouncer
  module Services
    class ServiceObject
      class << self

        def run!(*args, &block)
          service = new(*args)
          yield(service) if block_given?
          service.run
        end

      end

      def phonebook
        @phonebook ||= {}
      end

      def on(event, &block)
        phonebook[event] = block
        self
      end

      def fire event, *payload
        phonebook[event].call(*payload) unless phonebook[event].blank? and return
      end

      def method_missing(method, *args, &block)
        if block_given? || args.detect {|x| x.is_a? Proc}
          blk = block   || args.detect {|x| x.is_a? Proc}
          on(method, &blk)
        end
      end

    end
  end
end
