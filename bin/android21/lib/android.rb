require 'singleton'

class Android
  include Singleton
  attr_accessor :id, :type, :name, :computer, :user, :os, :ip, :country, :city, :status, :inators, :ws
  def initialize
    @id = "1234"              # unique id
    @type = "Master"          # slave/master
    @name = "Android 21"      # name of client
    @computer = "Unknown"     # machine name
    @user = "Defalt"          # user
    @os = "Unkonwn"           # operating system
    @ip = "Unkonwn"           #ip address
    @country = "Unkonwn"      # country
    @city = "Unkonwn"         # city
    @status = "Unkonwn"       # online/offline/error
    @inators = []             # inators
    @ws = nil                 # websocket object
  end

  def android
    inators = []
    @inators.each { |inator| inators << { "id" => inator.id, "name" => inator.name } }
    {
      "header" => "android",
      "payload" => {
        "id" => @id,
        "type" => @type,
        "name" => @name,
        "computer" => @computer,
        "user" => @user,
        "os" => @os,
        "ip" => @ip,
        "country" => @country,
        "city" => @city,
        "inators" => inators
      },
      "trailer" => "this is andorid 21 test"
    }.to_json
  end

  def connect(server)
    EM.run {
      @ws = Faye::WebSocket::Client.new(server)

      @ws.on :open do |event|
        p [:open]
        @ws.send(android)
      end

      @ws.on :message do |event|
        p [:message, event.data]
        begin
          packet = JSON.parse(event.data)

          header = packet['header']       # header
          payload = packet['payload']     # payload
          trailer = packet['trailer']     # trailer

          if header == "pwn" then
            inator = packet['payload']['inator']
            data = packet['payload']['data']
            log = trailer
            input(inator, data, log)
          else
            #disconnect
          end
        rescue Exception => ex
          puts ex
        end
      end

      @ws.on :close do |event|
        p [:close, event.code, event.reason]
        @ws = nil
        sleep 1
        connect server
      end
    }
  end

  def disconnect
    @ws.close
  end

  def input(inator, data, log)
    inator = @inators.find { |i| i.id == inator }
    inator.input(data, log)
  end

  def output(inator, data, log)
    packet = {
      "header" => "data",
      "payload" => { "android" => @id, "inator" => inator, "data" => data },
      "trailer" => log
    }.to_json
    @ws.send packet
  end
end
