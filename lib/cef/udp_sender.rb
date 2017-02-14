module CEF
  require 'socket'

  class UDPSender < Sender
    def initialize(receiver='127.0.0.1', port=514)
      @receiver = receiver
      @port = port
    end

    #fire the message off
    def emit(event)
      self.socksetup if self.sock.nil?
      # process eventDefaults - we are expecting a hash here. These will
      # override any values in the events passed to us. i know. brutal.
      unless self.eventDefaults.nil?
        self.eventDefaults.each do |k,v|
          event.send("%s=" % k,v)
        end
      end
      self.sock.send event.to_s, 0
    end

    def socksetup
      @sock=UDPSocket.new
      @sock.connect(@receiver, @port)
    end
  end
end
