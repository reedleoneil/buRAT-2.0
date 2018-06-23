require 'singleton'

class Android
  include Singleton
  attr_accessor :id, :type, :name, :computer, :user, :os, :ip, :country, :city, :status, :inators, :ws
  def initialize
    @id = "1234"              # unique id
    @type = "Master"         # slave/master
    @name = "Android 21"          # name of client
    @computer = "Unknown"  # machine name
    @user = "Defalt"          # user
    @os = "Unkonwn"              # operating system
    @ip = "Unkonwn"              # ip address
    @country = "Unkonwn"    # country
    @city = "Unkonwn"          # city
    @status = "Unkonwn"      # online/offline/error
    @inators = []    # inators
    @ws = nil              # websocket object
  end

  def android
    '{"header": "android", "payload": {"id": "1234", "type": "Slave", "name": "Android 22", "computer": "4tech-pc", "user": "verbatim", "os": "Linux", "ip": "192.168.1.2", "country": "Philippines", "city": "Minalin", "inators": [{"id": "1111", "name": "Remote Shell"}, {"id": "2222", "name": "Remote Desktop"}, {"id": "3333", "name": "Remote Hack"}]}, "trailer": "whoami"}'
  end
end
