require 'faye/websocket'
require 'eventmachine'

class BuSocket < Inator
  def initialize(id)
    super(id, "Socket")
  end
  def connect(server)
    EM.run {
      ws = Faye::WebSocket::Client.new(server)
      Android.instance.ws = ws

      ws.on :open do |event|
        p [:open]
        ws.send(Android.instance.android)
      end

      ws.on :message do |event|
        p [:message, event.data]
        begin
          packet = JSON.parse(event.data)

          header = packet['header']       # header
          payload = packet['payload']     # payload
          trailer = packet['trailer']     # trailer

          if header == "pwn" then
            inator = Android.instance.inators.find { |inator| inator.id == packet['payload']['inator'] }
            inator.in(packet['payload']['data'], trailer)
          end
        rescue Exception => ex
          puts ex
        end
      end

      ws.on :close do |event|
        p [:close, event.code, event.reason]
        p "RED"
        ws = nil
        connect 'ws://localhost:10969'
      end
    }
  end
end
