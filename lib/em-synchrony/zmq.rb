require 'em-synchrony'
require 'ffi-rzmq'

module EM::Synchrony
  module ZMQ
    module NotifyHandler
      def self.included(base)
        base.class_eval do
          attr_accessor :notify_clb
        end
      end
      def notify_readable
        notify_clb.call
      end

      def notify_writable
        notify_clb.call
      end
    end    

    class FiberBlock
      def initialize
        @waiters = []
      end
      def lock
        @waiters << Fiber.current
        Fiber.yield
      end

      def wake
        w = @waiters.shift
        w.resume if w
      end
    end
  end
end

module ZMQ
  class Socket
    def initialize(*args)
      super
      fd, = [].tap { |a| getsockopt(ZMQ::FD, a) }
      c = EM.watch(fd, EM::Synchrony::ZMQ::NotifyHandler)
      c.notify_clb = proc { @synchrony_send.wake; @synchrony_recv.wake }
      c.notify_readable = true
      @synchrony_send = EM::Synchrony::ZMQ::FiberBlock.new
      @synchrony_recv = EM::Synchrony::ZMQ::FiberBlock.new
    end

    alias :bsend :send
    def send(message, flags = 0)
      return bsend(message, flags) if (flags & ZMQ::NOBLOCK) != 0
      flags |= ZMQ::NOBLOCK
      loop do
        rc = bsend message, flags
        if rc == -1 && ZMQ::Util.errno == EAGAIN
          @synchrony_send.lock
        else
          @synchrony_recv.wake
          @synchrony_send.wake
          return rc
        end
      end
    end

    alias :brecv :recv
    def recv(message, flags = 0)
      return brecv(message, flags) if (flags & ZMQ::NOBLOCK) != 0
      flags |= ZMQ::NOBLOCK
      loop do
        rc = brecv message, flags
        if rc == -1 && ZMQ::Util.errno == EAGAIN
          @synchrony_recv.lock
        else
          @synchrony_send.wake
          @synchrony_recv.wake
          return rc
        end
      end
    end
  end
end