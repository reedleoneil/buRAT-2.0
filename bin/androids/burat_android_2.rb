require 'faye/websocket'
require 'eventmachine'

EM.run {
  ws = Faye::WebSocket::Client.new('ws://127.0.0.1')

  ws.on :open do |event|
    p [:open]
    ws.send('{"header": "identification", "payload": {"id": "4", "type": "Android", "name": "Android 22", "computer": "4tech-pc", "user": "verbatim", "os": "Linux", "ip": "192.168.1.2", "country": "Philippines", "city": "Minalin", "inators": [{"id": "1111", "name": "Remote Shell"}, {"id": "2222", "name": "Remote Desktop"}]}}')
  end

  ws.on :message do |event|
    p [:message, event.data]
    ws.send('{"header": "data", "payload":{"client.id": "3", "inator.id": "1111", "data": "asd"}}')
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end
}
