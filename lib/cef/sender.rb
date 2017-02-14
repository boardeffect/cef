module CEF
  require 'socket'

  class Sender
    attr_accessor :receiver, :receiverPort, :eventDefaults
    attr_reader   :sock
    def initialize(*args)
      Hash[*args].each { |argname, argval| self.send(("%s="%argname), argval) }
      @sock=nil
    end
  end

  #TODO: Implement relp/tcp senders
end
