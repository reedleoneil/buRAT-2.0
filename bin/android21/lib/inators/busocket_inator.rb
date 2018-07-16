class BuSocketInator < Inator
  def initialize(id, name, socket)
    super(id, name)
    @socket = socket
  end

  def in(android, data, log)

  end

  def set_host(host)
    @socket.host = host
  end

  def set_reconnect_enabled(value)
    @socket.reconnect_enabled = value
  end

  def set_reconnect_interval(interval)
    @socket.reconnect_interval = interval
  end
end
