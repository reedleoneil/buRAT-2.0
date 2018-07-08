class BuSocket
  attr_accessor :socket, :host, :reconnect_enabled, :reconnect_interval
  def initialize(socket, host, reconnect_enabled, reconnect_interval)
    @socket = socket
    @host = host
    @reconnect_enabled = reconnect_enabled
    @reconnect_interval = reconnect_interval
  end
end
