module CEF
  require 'socket'
  require 'openssl'

  class TLSSender < Sender
    def initialize(receiver, port, cert, key, ca_chain, maxlength=2048)
      @receiver = receiver
      @port = port
      @maxlength = maxlength

      @ssl_context = OpenSSL::SSL::SSLContext.new
      @ssl_context.cert = OpenSSL::X509::Certificate.new(cert)
      @ssl_context.key = OpenSSL::PKey.read(key)

      # Split CA chain into an array of individual certs
      cert_delimeter = '-----END CERTIFICATE-----'
      ca_certs = ca_chain.split(cert_delimeter).collect do |cert|
        OpenSSL::X509::Certificate.new(cert + cert_delimeter)
      end

      # Add each CA chain cert to the cert store
      cert_store = OpenSSL::X509::Store.new
      ca_certs.each do |cert|
        cert_store.add_cert(cert)
      end

      # Associate the cert store with the context to verify the server cert
      @ssl_context.cert_store = cert_store
      @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end

    #fire the message off
    def emit(event)
      tcp_sock = TCPSocket.new(@receiver, @port)
      @sock = OpenSSL::SSL::SSLSocket.new tcp_sock, @ssl_context
      @sock.connect
      begin
        # process eventDefaults - we are expecting a hash here. These will
        # override any values in the events passed to us. i know. brutal.
        unless self.eventDefaults.nil?
          self.eventDefaults.each do |k,v|
            event.send("%s=" % k,v)
          end
        end
        @sock.puts truncate(event.to_s)
      ensure
        @sock.close
      end
    end

    def truncate(event)
      event.to_s[0..@maxlength-1]
    end
  end
end
