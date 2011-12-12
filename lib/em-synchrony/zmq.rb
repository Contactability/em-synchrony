require 'em-synchrony'
require 'ffi-rzmq'
module ZMQ
  class Socket
    alias :bsend :send
    def send(message, flags = 0)
      return bsend(message, flags) if (flags & ZMQ::NOBLOCK) != 0
      flags |= ZMQ::NOBLOCK
      while EM.reactor_running? do
        sock_wait false, true
        rc = bsend message, flags
        unless rc == -1 && ZMQ::Util.errno == EAGAIN
          return rc
        end
      end
    end

    alias :brecv :recv
    def recv(message, flags = 0)
      return brecv(message, flags) if (flags & ZMQ::NOBLOCK) != 0
      flags |= ZMQ::NOBLOCK
      while EM.reactor_running? do
        sock_wait true, false
        rc = brecv message, flags
        unless rc == -1 && ZMQ::Util.errno == EAGAIN
          return rc
        end
      end
    end

    protected

    def sock_wait(read = false, write = false)
      events, = [].tap { |a| getsockopt(ZMQ::EVENTS, a) }
      if read && (events & ZMQ::POLLIN) == ZMQ::POLLIN
        return
      elsif write && (events & ZMQ::POLLOUT) == ZMQ::POLLOUT
        return
      else
        fd, = [].tap { |a| getsockopt(ZMQ::FD, a) }
        EM::Synchrony.trampoline(fd, read: read, write: write)
      end
    end
  end
end