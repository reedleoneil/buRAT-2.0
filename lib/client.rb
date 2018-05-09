class Client
  attr_accessor :id, :type, :name, :computer, :user, :os, :ip, :country, :city, :status, :inators, :ws
  def initialize(id, type, name, computer, user, os, ip, country, city, status, inators, ws)
    @id = id              # unique id
    @type = type          # slave/master
    @name = name          # name of client
    @computer = computer  # machine name
    @user = user          # user
    @os = os              # operating system
    @ip = ip              # ip address
    @country = country    # country
    @city = city          # city
    @status = status      # online/offline/error
    @inators = inators    # inators
    @ws = ws              # websocket object
  end
end
